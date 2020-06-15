using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class edge_detect : MonoBehaviour
{
	private Material mat;
	public Material sobel_color_mat;
	public Material sobel_depth_mat;
	public Material LaplacianDepthNormalMat;

	void OnRenderImage (RenderTexture sourceTexture, RenderTexture destTexture)
	{
		if(mat == null)
		{
			mat = sobel_color_mat;
		}

		if (mat != null)
		{
			Graphics.Blit(sourceTexture, destTexture, mat);
		}
	}

	void OnGUI()
	{
		GUI.skin.button.fontSize = 100;
		if(GUILayout.Button("SobelColor"))
        {
        	Camera camera = this.GetComponent<Camera>();
        	camera.depthTextureMode = DepthTextureMode.None;
        	mat = sobel_color_mat;
        }
        else if(GUILayout.Button("SobelDepth"))
        {
        	Camera camera = this.GetComponent<Camera>();
        	camera.depthTextureMode = DepthTextureMode.Depth;
        	mat = sobel_depth_mat;
        }
        else if(GUILayout.Button("LaplacianDepthNormal"))
        {
        	Camera camera = this.GetComponent<Camera>();
        	camera.depthTextureMode = DepthTextureMode.DepthNormals;
        	mat = LaplacianDepthNormalMat;
        }
	}
}
