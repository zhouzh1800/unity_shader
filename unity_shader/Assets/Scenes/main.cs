using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class main : MonoBehaviour
{
    void OnGUI()
    {
    	GUI.skin.button.fontSize = 100;
        if(GUILayout.Button("screen_border"))
        {
        	SceneManager.LoadScene("screen_border");
        }
        else if(GUILayout.Button("edge_detect"))
        {
        	SceneManager.LoadScene("edge_detect");
        }
    }
}
