import 'package:flutter/material.dart';

class ShimmerLoadingEffect extends StatefulWidget {
  final bool isLoading;
  final Widget child;
  const ShimmerLoadingEffect({
    this.isLoading = true,
    this.child
  });

  @override
  _ShimmerLoadingEffectState createState() => _ShimmerLoadingEffectState();
}

class _ShimmerLoadingEffectState extends State<ShimmerLoadingEffect> {

  Listenable _shimmerChanges;

  void didChangeDependencies()
  {
    super.didChangeDependencies();
    if(_shimmerChanges != null)
    {
      _shimmerChanges.removeListener(_onShimmerChange);
    }
    _shimmerChanges = Shimmer.of(context).shimmerChanges;
    if(_shimmerChanges != null)
    {
      _shimmerChanges.addListener(_onShimmerChange);
    }
  }

  @override
  void dispose()
  {
    _shimmerChanges.removeListener(_onShimmerChange);
    super.dispose();
  }

  void _onShimmerChange()
  {
    if(widget.isLoading)
    {
      setState(() {

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if(!widget.isLoading) return widget.child;

    final shimmer = Shimmer.of(context);

    if(!shimmer.isSized)
    {
      return SizedBox();
    }

    final shimmerSize = shimmer.size;
    final gradient = shimmer.gradient;
    final offsetWithinShimmer = shimmer.getDescendantOffset(
      descendant: context.findRenderObject() as RenderBox
    );

    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds)
      {
        return gradient.createShader(
          Rect.fromLTWH(
              -offsetWithinShimmer.dx,
              -offsetWithinShimmer.dy,
              shimmerSize.width,
              shimmerSize.height)
        );
      },
      child: widget.child,
    );
  }
}

class Shimmer extends StatefulWidget {

  Shimmer({this.linearGradient, this.child});

  final LinearGradient linearGradient;
  final Widget child;

  static ShimmerState of(BuildContext context)
  {
    return context.findAncestorStateOfType<ShimmerState>();
  }
  @override
  ShimmerState createState() => ShimmerState();
}

class ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  AnimationController _shimmerController;

  @override
  void initState()
  {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));
  }

  @override
  void dispose()
  {
    _shimmerController.dispose();
    super.dispose();
  }

  Listenable get shimmerChanges => _shimmerController;

  Gradient get gradient => LinearGradient(
    colors: widget.linearGradient.colors,
    stops: widget.linearGradient.stops,
    begin: widget.linearGradient.begin,
    end: widget.linearGradient.end,
    transform: _SlidingGradientTransform(slidePercent: _shimmerController.value)
  );

  bool get isSized => (context.findRenderObject() as RenderBox).hasSize;
  Size get size => (context.findRenderObject() as RenderBox).size;

  Offset getDescendantOffset({
    RenderBox descendant,
    Offset offset = Offset.zero
  }){
    final shimmerBox = context.findRenderObject() as RenderBox;
    return descendant.localToGlobal(offset, ancestor: shimmerBox);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox();
  }
}

class _SlidingGradientTransform extends GradientTransform {
  _SlidingGradientTransform({
    this.slidePercent
  });
  final double slidePercent;


  @override
  Matrix4 transform(Rect bounds, {TextDirection textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}
