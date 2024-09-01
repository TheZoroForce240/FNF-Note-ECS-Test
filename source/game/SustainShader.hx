package game;
import flixel.system.FlxAssets;
import flixel.graphics.tile.FlxGraphicsShader;

//unused
class SustainShader extends FlxShader
{
    @:glFragmentSource('
        #pragma header

        uniform float clipY;
        varying float yValueV;
        uniform int downscroll;
        
        void main()
        {
            if ((downscroll == 0 && yValueV <= clipY) || (downscroll != 0 && yValueV >= clipY)) {
                gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
                return;
            }
            vec4 spritecolor = flixel_texture2D(bitmap, openfl_TextureCoordv);
        
            gl_FragColor = spritecolor;
        }
    ')

	@:glVertexSource("
        #pragma header
        
        attribute float alpha;
        attribute vec4 colorMultiplier;
        attribute vec4 colorOffset;
        uniform bool hasColorTransform;

        attribute float yValue;
        varying float yValueV;
        
        void main(void)
        {
            #pragma body
            
            openfl_Alphav = openfl_Alpha * alpha;
            yValueV = yValue;
            
            if (hasColorTransform)
            {
                openfl_ColorOffsetv = colorOffset / 255.0;
                openfl_ColorMultiplierv = colorMultiplier;
            }
        }")

    public function new()
    {
        super();
    }
}