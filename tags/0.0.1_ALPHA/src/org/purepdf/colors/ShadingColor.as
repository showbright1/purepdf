package org.purepdf.colors
{
	import it.sephiroth.utils.ObjectHash;
	
	import org.purepdf.pdf.PdfShadingPattern;

	public class ShadingColor extends ExtendedColor
	{
		private var _shadingPattern: PdfShadingPattern;
		
		public function ShadingColor( pattern: PdfShadingPattern )
		{
			super( TYPE_SHADING );
			setValue( 0.5, 0.5, 0.5 );
			_shadingPattern = pattern;
		}
		
		public function get shadingPattern(): PdfShadingPattern
		{
			return _shadingPattern;
		}
		
		override public function equals( obj: Object ): Boolean
		{
			return this == obj;
		}
		
		override public function hashCode() : int
		{
			return _shadingPattern.hashCode();
		}
	}
}