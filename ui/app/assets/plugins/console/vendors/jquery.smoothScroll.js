(function($){

	// Wheel event
	function wheel(el, callback) {
		var mousewheelevt = (/Firefox/i.test(navigator.userAgent))? "MozMousePixelScroll" : "mousewheel"; // Firefox events are different
		function handler(e) {
			e = e || window.event;
			var normalized = e.detail ? e.detail * -1 : e.wheelDelta / 3;
			// Prevent default if on the edges
			if (el.scrollTop > 0 && el.scrollTop < (el.scrollHeight - el.offsetHeight))
				e.preventDefault();
			return callback.call(el, normalized);
		}
		el.addEventListener(mousewheelevt, handler, false);
	}

	// requestAnimationFrame polyfill
	var requestAnimFrame = window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.msRequestAnimationFrame || window.oRequestAnimationFrame || function(f){window.setTimeout(f, 1000 / 60);}

	$.fn.smoothScroll = function(){
		return $(this).map(function(){
			// Element
			var el = this, $el = $(el);

			// Functions
			var mousedown, showHandler, updateHandler, hideHandler, resize;

			// -------------------
			// HANDLER
			// We need thos variable in the scope
			var handler, $handler, _top, _left, _bottom, _right, _height, _width, _sheight, _swidth, _ratio, _bar;

			// State
			var _memoPos, _memoClick;

			$handler = $("<span class='smoothScroll'/>").appendTo("body");
			handler = $handler[0]

			function refreshHandler(){
				_top = $el.offset().top
				_left = $el.offset().left
				_bottom = _top + _height
				_right = _left + _width
				_height = el.clientHeight
				_width = el.clientWidth
				_sheight = el.scrollHeight
				_swidth = el.scrollWidth
				_ratio = _height / _sheight

				if (!handler.style.top)
					handler.style.top = _top + "px";
				handler.style.left = (_right-9) + "px";
				handler.style.height = _height * _ratio + "px";
				_bar = handler.clientHeight
			}

			// Drag
			showHandler = function(){
				if (_ratio < 1) $handler.addClass("show");
			}
			updateHandler = function(){
				if (_sheight != el.scrollHeight) refreshHandler();
				handler.style.top = (el.scrollTop * (_height-_bar) / (_sheight-_height) + _top) + "px";
			}
			hideHandler = function(){
				$handler.removeClass("show");            
			}

			$handler.on("mousedown.smoothScroll", function(e){
				e.preventDefault();
				$handler.addClass("drag");

				_memoClick = e.clientY;
				_memoPos = el.scrollTop;
				$(document.body).on("mousemove.smoothScroll", function(e){
					el.scrollTop = _memoPos + (e.clientY - _memoClick)/_ratio;
					updateHandler();
				}).on("mouseup", function(){
					$(document.body).off("mousemove.smoothScroll mouseup.smoothScroll");
					$handler.removeClass("drag");
				});
				return false; // Prevent text selection
			});
			// -------------------			

			// Scroll the div
			// This function must be very fast
			var timer;
			wheel(this, function(deltaY){
				this.scrollTop -= deltaY;
				if (!timer){
					timer = 1;
					$handler.addClass("move");
					(function animloop(){
						if (timer) requestAnimFrame(animloop);
						updateHandler();
					})();
				}
				clearTimeout(timer);
				timer = setTimeout(function(){
					$handler.removeClass("move");
					timer = false;
				}, 100);
			})

			remove = function(){
				$handler.off("mousedown.smoothScroll").remove();
				$(window).off("resize.smoothScroll", resize);
				$el.off("remove.smoothScroll");
				// Hardcore
				delete el, $el, mousedown, showHandler, updateHandler, hideHandler, resize, handler, $handler, _top, _left, _bottom, _right, _height, _width, _sheight, _swidth, _ratio, _bar, _memoPos, _memoClick;
			}

			$(window).on("resize.smoothScroll", refreshHandler).trigger("resize.smoothScroll");

			// Manage the handler
			$el
				.css("overflow-y", "hidden")
				.mouseenter(function(){
					refreshHandler();
					showHandler();
				})
				.mouseleave(function(){
					hideHandler();
				})
				.on("remove.smoothScroll", remove);

		});
	}


})(jQuery);
