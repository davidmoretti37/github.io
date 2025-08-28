import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:async';
import 'dart:math' as math;

class AdvancedInfiniteScroll extends StatefulWidget {
  final double? width;
  final double? maxHeight;
  final double negativeMargin;
  final List<Widget> items;
  final double itemMinHeight;
  final bool isTilted;
  final String tiltDirection;
  final bool autoplay;
  final double autoplaySpeed;
  final String autoplayDirection;
  final bool pauseOnHover;

  const AdvancedInfiniteScroll({
    super.key,
    this.width,
    this.maxHeight,
    this.negativeMargin = -8.0, // -0.5em ≈ -8px
    required this.items,
    this.itemMinHeight = 150,
    this.isTilted = false,
    this.tiltDirection = "left",
    this.autoplay = false,
    this.autoplaySpeed = 0.5,
    this.autoplayDirection = "down",
    this.pauseOnHover = false,
  });

  @override
  State<AdvancedInfiniteScroll> createState() => _AdvancedInfiniteScrollState();
}

class _AdvancedInfiniteScrollState extends State<AdvancedInfiniteScroll>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Timer? _autoplayTimer;
  List<double> _itemPositions = [];
  double _totalHeight = 0;
  List<Widget> _doubledItems = [];
  bool _isHovered = false;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _doubledItems = [...widget.items, ...widget.items];
    _initializePositions();
    _startAutoplay();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _autoplayTimer?.cancel();
    super.dispose();
  }

  void _initializePositions() {
    if (_doubledItems.isEmpty) return;
    
    final itemHeight = widget.itemMinHeight;
    final itemMarginTop = widget.negativeMargin;
    final totalItemHeight = itemHeight + itemMarginTop;
    // Correct total height for a single list
    _totalHeight = (itemHeight * widget.items.length) + 
                   (itemMarginTop * (widget.items.length - 1));

    _itemPositions = List.generate(
      _doubledItems.length,
      (i) => i * totalItemHeight,
    );
  }

  void _startAutoplay() {
    if (!widget.autoplay) return;
    
    _autoplayTimer = Timer.periodic(
      const Duration(milliseconds: 16), // ~60fps
      (timer) {
        if (_isHovered && widget.pauseOnHover) return;
        if (_isDragging) return;
        
        final directionFactor = widget.autoplayDirection == "down" ? 1.0 : -1.0;
        final speedPerFrame = widget.autoplaySpeed * directionFactor;
        
        setState(() {
          for (int i = 0; i < _itemPositions.length; i++) {
            _itemPositions[i] = _wrapPosition(_itemPositions[i] + speedPerFrame);
          }
        });
      },
    );
  }

  double _wrapPosition(double position) {
    final singleListHeight = (widget.itemMinHeight + widget.negativeMargin) * widget.items.length;
    final totalListHeight = singleListHeight * 2;

    if (position >= singleListHeight) {
      return position - totalListHeight;
    } else if (position < -singleListHeight) {
      return position + totalListHeight;
    }
    return position;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    
    final deltaY = details.delta.dy;
    final distance = deltaY * 5; // Sensitivity multiplier
    
    setState(() {
      for (int i = 0; i < _itemPositions.length; i++) {
        _itemPositions[i] = _wrapPosition(_itemPositions[i] + distance);
      }
    });
  }

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      final deltaY = event.scrollDelta.dy;
      final distance = -deltaY * 2; // Wheel sensitivity
      
      setState(() {
        for (int i = 0; i < _itemPositions.length; i++) {
          _itemPositions[i] = _wrapPosition(_itemPositions[i] + distance);
        }
      });
    }
  }

  Matrix4 _getTiltTransform() {
    if (!widget.isTilted) return Matrix4.identity();
    
    final matrix = Matrix4.identity();
    if (widget.tiltDirection == "left") {
      matrix.rotateX(20 * math.pi / 180); // 20 degrees
      matrix.rotateZ(-20 * math.pi / 180);
      // Note: Flutter doesn't have direct skew, using perspective instead
      matrix.setEntry(0, 1, 0.2); // Approximate skew effect
    } else {
      matrix.rotateX(20 * math.pi / 180);
      matrix.rotateZ(20 * math.pi / 180);
      matrix.setEntry(0, 1, -0.2);
    }
    return matrix;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (widget.pauseOnHover) {
          setState(() {
            _isHovered = true;
          });
        }
      },
      onExit: (_) {
        if (widget.pauseOnHover) {
          setState(() {
            _isHovered = false;
          });
        }
      },
      child: Listener(
        onPointerSignal: _handlePointerSignal,
        child: GestureDetector(
          onPanStart: _handlePanStart,
          onPanUpdate: _handlePanUpdate,
          onPanEnd: _handlePanEnd,
          child: Container(
            width: widget.width ?? MediaQuery.of(context).size.width,
            height: widget.maxHeight ?? MediaQuery.of(context).size.height,
            child: ClipRect(
              child: Transform(
                alignment: Alignment.center,
                transform: widget.isTilted ? _getTiltTransform() : Matrix4.identity(),
                child: Stack(
                  children: List.generate(
                    _doubledItems.length,
                    (index) {
                      if (index >= _itemPositions.length) {
                        return const SizedBox.shrink();
                      }
                      return AnimatedPositioned(
                        duration: _isDragging 
                            ? Duration.zero 
                            : const Duration(milliseconds: 100),
                        curve: Curves.easeOut,
                        left: 0,
                        top: _itemPositions[index],
                        child: Container(
                          width: widget.width ?? MediaQuery.of(context).size.width,
                          height: widget.itemMinHeight,
                          margin: EdgeInsets.only(top: widget.negativeMargin.abs()),
                          transform: Matrix4.translationValues(0, widget.negativeMargin, 0),
                          child: _doubledItems[index],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Example usage widget
class AdvancedInfiniteScrollDemo extends StatelessWidget {
  const AdvancedInfiniteScrollDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final items = List.generate(
      20,
      (index) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.withOpacity(0.8),
              Colors.blue.withOpacity(0.6),
              Colors.cyan.withOpacity(0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Item ${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Advanced scroll item',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: AdvancedInfiniteScroll(
        items: items,
        itemMinHeight: 120,
        negativeMargin: -10,
        isTilted: false,
        autoplay: true,
        autoplaySpeed: 1.0,
        autoplayDirection: "down",
        pauseOnHover: true,
      ),
    );
  }
}
