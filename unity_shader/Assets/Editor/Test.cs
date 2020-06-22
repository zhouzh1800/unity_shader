using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class Test
{
	[MenuItem("Assets/Custom/PrintMiddlePixel")]
	static void PrintMiddlePixel()
	{
		Texture2D tex = Selection.activeObject as Texture2D;
		Color c = tex.GetPixel(tex.width / 2, tex.height / 2);
		Debug.Log(c);
	}
}
