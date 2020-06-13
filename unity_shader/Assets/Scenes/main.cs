using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class main : MonoBehaviour
{
    void OnGUI()
    {
        if(GUILayout.Button("screen_border"))
        {
        	SceneManager.LoadScene("screen_border");
        }
    }
}
