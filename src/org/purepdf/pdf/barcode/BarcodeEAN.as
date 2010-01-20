package org.purepdf.pdf.barcode
{
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.errors.ConversionError;
	import org.purepdf.errors.NonImplementatioError;
	import org.purepdf.errors.RuntimeError;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.fonts.BaseFont;

	public class BarcodeEAN extends Barcode
	{
		private static const GUARD_EMPTY: Vector.<int> = new Vector.<int>(0);
		private static const GUARD_UPCA: Vector.<int> = Vector.<int>([0, 2, 4, 6, 28, 30, 52, 54, 56, 58]);
		private static const GUARD_EAN13: Vector.<int> = Vector.<int>([0, 2, 28, 30, 56, 58]);
		private static const GUARD_EAN8: Vector.<int> = Vector.<int>([0, 2, 20, 22, 40, 42]);
		private static const GUARD_UPCE: Vector.<int> = Vector.<int>([0, 2, 28, 30, 32]);
		private static const TEXTPOS_EAN13: Vector.<Number> = Vector.<Number>([6.5, 13.5, 20.5, 27.5, 34.5, 41.5, 53.5, 60.5, 67.5, 74.5, 81.5, 88.5]);
		private static const TEXTPOS_EAN8: Vector.<Number> = Vector.<Number>([6.5, 13.5, 20.5, 27.5, 39.5, 46.5, 53.5, 60.5]);
		private static const BARS: Vector.<Vector.<int>> = 
			Vector.<Vector.<int>>([
				Vector.<int>([3, 2, 1, 1]), // 0
				Vector.<int>([2, 2, 2, 1]), // 1
				Vector.<int>([2, 1, 2, 2]), // 2
				Vector.<int>([1, 4, 1, 1]), // 3
				Vector.<int>([1, 1, 3, 2]), // 4
				Vector.<int>([1, 2, 3, 1]), // 5
				Vector.<int>([1, 1, 1, 4]), // 6
				Vector.<int>([1, 3, 1, 2]), // 7
				Vector.<int>([1, 2, 1, 3]), // 8
				Vector.<int>([3, 1, 1, 2])  // 9
			]);
		
		private static const TOTALBARS_EAN13: int = 11 + 12 * 4;
		private static const TOTALBARS_EAN8: int = 11 + 8 * 4;
		private static const TOTALBARS_UPCE: int = 9 + 6 * 4;
		private static const TOTALBARS_SUPP2: int = 13;
		private static const TOTALBARS_SUPP5: int = 31;
		private static const ODD: int = 0;
		private static const EVEN: int = 1;
		private static const PARITY13: Vector.<Vector.<int>> =
			Vector.<Vector.<int>>([
				Vector.<int>([ODD, ODD,  ODD,  ODD,  ODD,  ODD]),  // 0
				Vector.<int>([ODD, ODD,  EVEN, ODD,  EVEN, EVEN]), // 1
				Vector.<int>([ODD, ODD,  EVEN, EVEN, ODD,  EVEN]), // 2
				Vector.<int>([ODD, ODD,  EVEN, EVEN, EVEN, ODD]),  // 3
				Vector.<int>([ODD, EVEN, ODD,  ODD,  EVEN, EVEN]), // 4
				Vector.<int>([ODD, EVEN, EVEN, ODD,  ODD,  EVEN]), // 5
				Vector.<int>([ODD, EVEN, EVEN, EVEN, ODD,  ODD]),  // 6
				Vector.<int>([ODD, EVEN, ODD,  EVEN, ODD,  EVEN]), // 7
				Vector.<int>([ODD, EVEN, ODD,  EVEN, EVEN, ODD]),  // 8
				Vector.<int>([ODD, EVEN, EVEN, ODD,  EVEN, ODD])   // 9
			]);
		
		private static const PARITY2: Vector.<Vector.<int>> =
			Vector.<Vector.<int>>([
				Vector.<int>([ODD,  ODD]),   // 0
				Vector.<int>([ODD,  EVEN]),  // 1
				Vector.<int>([EVEN, ODD]),   // 2
				Vector.<int>([EVEN, EVEN])   // 3
			]);
		
		private static const PARITY5: Vector.<Vector.<int>> =
			Vector.<Vector.<int>>([
				Vector.<int>([EVEN, EVEN, ODD,  ODD,  ODD]),  // 0
				Vector.<int>([EVEN, ODD,  EVEN, ODD,  ODD]),  // 1
				Vector.<int>([EVEN, ODD,  ODD,  EVEN, ODD]),  // 2
				Vector.<int>([EVEN, ODD,  ODD,  ODD,  EVEN]), // 3
				Vector.<int>([ODD,  EVEN, EVEN, ODD,  ODD]),  // 4
				Vector.<int>([ODD,  ODD,  EVEN, EVEN, ODD]),  // 5
				Vector.<int>([ODD,  ODD,  ODD,  EVEN, EVEN]), // 6
				Vector.<int>([ODD,  EVEN, ODD,  EVEN, ODD]),  // 7
				Vector.<int>([ODD,  EVEN, ODD,  ODD,  EVEN]), // 8
				Vector.<int>([ODD,  ODD,  EVEN, ODD,  EVEN])  // 9
			]);
		
		private static const PARITYE: Vector.<Vector.<int>> =
			Vector.<Vector.<int>>([
				Vector.<int>([EVEN, EVEN, EVEN, ODD,  ODD,  ODD]),  // 0
				Vector.<int>([EVEN, EVEN, ODD,  EVEN, ODD,  ODD]),  // 1
				Vector.<int>([EVEN, EVEN, ODD,  ODD,  EVEN, ODD]),  // 2
				Vector.<int>([EVEN, EVEN, ODD,  ODD,  ODD,  EVEN]), // 3
				Vector.<int>([EVEN, ODD,  EVEN, EVEN, ODD,  ODD]),  // 4
				Vector.<int>([EVEN, ODD,  ODD,  EVEN, EVEN, ODD]),  // 5
				Vector.<int>([EVEN, ODD,  ODD,  ODD,  EVEN, EVEN]), // 6
				Vector.<int>([EVEN, ODD,  EVEN, ODD,  EVEN, ODD]),  // 7
				Vector.<int>([EVEN, ODD,  EVEN, ODD,  ODD,  EVEN]), // 8
				Vector.<int>([EVEN, ODD,  ODD,  EVEN, ODD,  EVEN])  // 9
			]);

		public function BarcodeEAN()
		{
			super();
			try 
			{
				x = 0.8;
				font = BaseFont.createFont( BaseFont.HELVETICA, BaseFont.WINANSI, BaseFont.NOT_EMBEDDED );
				size = 8;
				baseline = size;
				barHeight = size * 3;
				guardBars = true;
				codeType = EAN13;
				code = "";
			}
			catch( e: Error ) 
			{
				throw new ConversionError(e);
			}
		}
		
		public static function getBarsEAN13( _code: String ): Vector.<int>
		{
			var code: Vector.<int> = new Vector.<int>( _code.length, true);
			var k: int;
			for ( k = 0; k < code.length; ++k )
				code[k] = _code.charCodeAt( k ) - 48;
			
			var c: int;
			var stripes: Vector.<int>;
			var bars: Vector.<int> = new Vector.<int>(TOTALBARS_EAN13,true);
			var pb: int = 0;
			bars[pb++] = 1;
			bars[pb++] = 1;
			bars[pb++] = 1;
			var sequence: Vector.<int> = PARITY13[code[0]];
			for( k = 0; k < sequence.length; ++k )
			{
				c = code[k + 1];
				stripes = BARS[c];
				if( sequence[k] == ODD )
				{
					bars[pb++] = stripes[0];
					bars[pb++] = stripes[1];
					bars[pb++] = stripes[2];
					bars[pb++] = stripes[3];
				} else 
				{
					bars[pb++] = stripes[3];
					bars[pb++] = stripes[2];
					bars[pb++] = stripes[1];
					bars[pb++] = stripes[0];
				}
			}
			bars[pb++] = 1;
			bars[pb++] = 1;
			bars[pb++] = 1;
			bars[pb++] = 1;
			bars[pb++] = 1;
			
			for( k = 7; k < 13; ++k )
			{
				c = code[k];
				stripes = BARS[c];
				bars[pb++] = stripes[0];
				bars[pb++] = stripes[1];
				bars[pb++] = stripes[2];
				bars[pb++] = stripes[3];
			}
			bars[pb++] = 1;
			bars[pb++] = 1;
			bars[pb++] = 1;
			return bars;
		}

		override public function getBarcodeSize(): RectangleElement
		{
			var width: Number = 0;
			var height: Number = barHeight;

			if ( font != null )
			{
				if ( baseline <= 0 )
					height += -baseline + size;
				else
					height += baseline - font.getFontDescriptor( BaseFont.DESCENT, size );
			}

			switch ( codeType )
			{
				case EAN13:
					width = x * ( 11 + 12 * 7 );
					if ( font != null )
					{
						width += font.getWidthPoint( code.charAt( 0 ), size );
					}
					break;
				case EAN8:
					width = x * ( 11 + 8 * 7 );
					break;
				case UPCA:
					width = x * ( 11 + 12 * 7 );
					if ( font != null )
					{
						width += font.getWidthPoint( code.charAt( 0 ), size ) + font.getWidthPoint( code.charAt( 11 ), size );
					}
					break;
				case UPCE:
					width = x * ( 9 + 6 * 7 );
					if ( font != null )
					{
						width += font.getWidthPoint( code.charAt( 0 ), size ) + font.getWidthPoint( code.charAt( 7 ), size );
					}
					break;
				case SUPP2:
					width = x * ( 6 + 2 * 7 );
					break;
				case SUPP5:
					width = x * ( 4 + 5 * 7 + 4 * 2 );
					break;
				default:
					throw new RuntimeError( "invalid code type" );
			}
			return new RectangleElement( 0, 0, width, height );
		}
		
		override public function placeBarcode( cb: PdfContentByte, barColor: RGBColor, textColor: RGBColor ): RectangleElement
		{
			var rect: RectangleElement = getBarcodeSize();
			var barStartX: Number = 0;
			var barStartY: Number = 0;
			var textStartY: Number = 0;
			if( font != null ) 
			{
				if (baseline <= 0)
					textStartY = barHeight - baseline;
				else {
					textStartY = -font.getFontDescriptor(BaseFont.DESCENT, size);
					barStartY = textStartY + baseline;
				}
			}
			switch (codeType) {
				case EAN13:
				case UPCA:
				case UPCE:
					if (font != null)
						barStartX += font.getWidthPoint(code.charAt(0), size);
					break;
			}
			var bars: Vector.<int> = null;
			var guard: Vector.<int> = GUARD_EMPTY;
			
			switch (codeType) 
			{
				case EAN13:
					bars = getBarsEAN13(code);
					guard = GUARD_EAN13;
					break;
				case EAN8:
					throw new NonImplementatioError();
					//bars = getBarsEAN8(code);
					guard = GUARD_EAN8;
					break;
				case UPCA:
					throw new NonImplementatioError();
					//bars = getBarsEAN13("0" + code);
					guard = GUARD_UPCA;
					break;
				case UPCE:
					throw new NonImplementatioError();
					//bars = getBarsUPCE(code);
					guard = GUARD_UPCE;
					break;
				case SUPP2:
					throw new NonImplementatioError();
					//bars = getBarsSupplemental2(code);
					break;
				case SUPP5:
					throw new NonImplementatioError();
					//bars = getBarsSupplemental5(code);
					break;
			}
			
			var keepBarX: Number = barStartX;
			var print: Boolean = true;
			var gd: Number = 0;
			if (font != null && baseline > 0 && guardBars) {
				gd = baseline / 2;
			}
			if (barColor != null)
				cb.setFillColor(barColor);
			
			var k: int;
			var c: String;
			var len: Number;
			var pX: Number;
			
			for( k = 0; k < bars.length; ++k )
			{
				var w: Number = bars[k] * x;
				if (print) 
				{
					if ( guard.indexOf(k) >= 0 )
						cb.rectangle(barStartX, barStartY - gd, w - inkSpreading, barHeight + gd);
					else
						cb.rectangle(barStartX, barStartY, w - inkSpreading, barHeight);
				}
				print = !print;
				barStartX += w;
			}
			cb.fill();
			if (font != null) {
				if (textColor != null)
					cb.setFillColor(textColor);
				cb.beginText();
				cb.setFontAndSize(font, size);
				switch (codeType) {
					case EAN13:
						cb.setTextMatrix( 1, 0, 0, 1, 0, textStartY );
						cb.showText( code.substring(0, 1) );
						for( k = 1; k < 13; ++k )
						{
							c = code.substring(k, k + 1);
							len = font.getWidthPoint(c, size);
							pX = keepBarX + TEXTPOS_EAN13[k - 1] * x - len / 2;
							cb.setTextMatrix( 1, 0, 0, 1, pX, textStartY );
							cb.showText( c );
						}
						break;
					
					case EAN8:
						for ( k = 0; k < 8; ++k )
						{
							c = code.substring(k, k + 1);
							len = font.getWidthPoint(c, size);
							pX = TEXTPOS_EAN8[k] * x - len / 2;
							cb.setTextMatrix( 1, 0, 0, 1, pX, textStartY );
							cb.showText( c );
						}
						break;
					
					case UPCA:
						cb.setTextMatrix( 1, 0, 0, 1, 0, textStartY);
						cb.showText(code.substring(0, 1));
						for (k = 1; k < 11; ++k) {
							c = code.substring(k, k + 1);
							len = font.getWidthPoint(c, size);
							pX = keepBarX + TEXTPOS_EAN13[k] * x - len / 2;
							cb.setTextMatrix( 1, 0, 0, 1, pX, textStartY );
							cb.showText(c);
						}
						cb.setTextMatrix( 1, 0, 0, 1, keepBarX + x * (11 + 12 * 7), textStartY);
						cb.showText(code.substring(11, 12));
						break;
					
					case UPCE:
						cb.setTextMatrix(1,0,0,1,0, textStartY);
						cb.showText(code.substring(0, 1));
						for (k = 1; k < 7; ++k) {
							c = code.substring(k, k + 1);
							len = font.getWidthPoint(c, size);
							pX = keepBarX + TEXTPOS_EAN13[k - 1] * x - len / 2;
							cb.setTextMatrix(1,0,0,1,pX, textStartY);
							cb.showText(c);
						}
						cb.setTextMatrix(1,0,0,1,keepBarX + x * (9 + 6 * 7), textStartY);
						cb.showText(code.substring(7, 8));
						break;
					
					case SUPP2:
					case SUPP5:
						for ( k = 0; k < code.length; ++k) {
							c = code.substring(k, k + 1);
							len = font.getWidthPoint(c, size);
							pX = (7.5 + (9 * k)) * x - len / 2;
							cb.setTextMatrix( 1,0,0,1,pX, textStartY );
							cb.showText(c);
						}
						break;
				}
				cb.endText();
			}
			return rect;
		}
	}
}