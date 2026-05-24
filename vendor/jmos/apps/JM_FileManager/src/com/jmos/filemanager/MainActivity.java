package com.jmos.filemanager;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Environment;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class MainActivity extends Activity {

    private ListView mListView;
    private TextView mPathTextView;
    private File mCurrentDir;
    private List<File> mFileList;
    private ArrayAdapter<String> mAdapter;
    private List<String> mFileNames;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // Dynamic programmatic UI to ensure zero layout xml compilation crashes!
        // Highly robust for AOSP compilation!
        setupLayout();

        mCurrentDir = Environment.getExternalStorageDirectory();
        if (mCurrentDir == null || !mCurrentDir.exists()) {
            mCurrentDir = new File("/sdcard");
        }

        updateFileList();
    }

    private void setupLayout() {
        android.widget.LinearLayout mainLayout = new android.widget.LinearLayout(this);
        mainLayout.setOrientation(android.widget.LinearLayout.VERTICAL);
        mainLayout.setPadding(24, 24, 24, 24);
        mainLayout.setBackgroundColor(0xFF0A0A1A); // Deep Night Blue background matching features

        // Top Branded Header
        TextView header = new TextView(this);
        header.setText("JM FILE MANAGER");
        header.setTextSize(22);
        header.setTypeface(android.graphics.Typeface.DEFAULT_BOLD);
        header.setTextColor(0xFF00E5FF); // Cyber Cyan
        header.setPadding(0, 0, 0, 16);
        mainLayout.addView(header);

        // Path indicator
        mPathTextView = new TextView(this);
        mPathTextView.setTextSize(14);
        mPathTextView.setTextColor(0xFF8888AA); // Slate muted text
        mPathTextView.setPadding(0, 0, 0, 20);
        mainLayout.addView(mPathTextView);

        // Divider
        View divider = new View(this);
        divider.setBackgroundColor(0x3300E5FF); // Cyber Cyan thin line
        divider.setMinimumHeight(2);
        mainLayout.addView(divider);

        // ListView
        mListView = new ListView(this);
        mListView.setDividerHeight(1);
        mListView.setPadding(0, 16, 0, 0);
        mainLayout.addView(mListView);

        setContentView(mainLayout);

        mFileNames = new ArrayList<>();
        mFileList = new ArrayList<>();

        // Adapter with Cyber-Cyan styling for items
        mAdapter = new ArrayAdapter<String>(this, android.R.layout.simple_list_item_1, mFileNames) {
            @Override
            public View getView(int position, View convertView, ViewGroup parent) {
                TextView view = (TextView) super.getView(position, convertView, parent);
                view.setTextColor(0xFFE0E0FF); // Off white text
                view.setTextSize(16);
                
                File file = mFileList.get(position);
                if (file.isDirectory()) {
                    view.setText("📁  " + file.getName());
                } else {
                    view.setText("📄  " + file.getName());
                }
                return view;
            }
        };

        mListView.setAdapter(mAdapter);
        mListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                File selectedFile = mFileList.get(position);
                if (selectedFile.isDirectory()) {
                    mCurrentDir = selectedFile;
                    updateFileList();
                } else {
                    Toast.makeText(MainActivity.this, "File: " + selectedFile.getName(), Toast.LENGTH_SHORT).show();
                }
            }
        });
    }

    private void updateFileList() {
        mPathTextView.setText("Path: " + mCurrentDir.getAbsolutePath());
        mFileNames.clear();
        mFileList.clear();

        File[] files = mCurrentDir.listFiles();
        
        // Add parent directory navigation if not at root
        File parent = mCurrentDir.getParentFile();
        if (parent != null && mCurrentDir.getPath().length() > 1 && !mCurrentDir.getAbsolutePath().equals(Environment.getExternalStorageDirectory().getAbsolutePath())) {
            mFileList.add(parent);
            mFileNames.add("..");
        }

        if (files != null) {
            List<File> dirList = new ArrayList<>();
            List<File> docList = new ArrayList<>();

            for (File file : files) {
                if (file.isDirectory()) {
                    dirList.add(file);
                } else {
                    docList.add(file);
                }
            }

            // Alphabetical sort
            Collections.sort(dirList);
            Collections.sort(docList);

            mFileList.addAll(dirList);
            mFileList.addAll(docList);

            for (File file : mFileList) {
                if (file.equals(parent)) {
                    continue;
                }
                mFileNames.add(file.getName());
            }
        }

        mAdapter.notifyDataSetChanged();
    }

    @Override
    public void onBackPressed() {
        File parent = mCurrentDir.getParentFile();
        if (parent != null && !mCurrentDir.getAbsolutePath().equals(Environment.getExternalStorageDirectory().getAbsolutePath())) {
            mCurrentDir = parent;
            updateFileList();
        } else {
            super.onBackPressed();
        }
    }
}
