package com.example.muapp;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

public class Login extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        final Button login = findViewById(R.id.button);


        login.setOnClickListener(new Button.OnClickListener() {

                                     @Override
                                     public void onClick(View view) {

                                         launchActivity();

                                     }
                                 }
        );


    }

    private void launchActivity() {
        Intent intent = new Intent(this, News.class);
        startActivity(intent);
    }
}
