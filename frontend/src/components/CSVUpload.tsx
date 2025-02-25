import React, { useState } from 'react';
import { useDropzone } from 'react-dropzone';
import { uploadProducts } from '../api/products';

interface CSVUploadProps {
  onUploadSuccess: () => void;
  setUploadMessage: (msg: string) => void;
}

const CSVUpload: React.FC<CSVUploadProps> = ({ onUploadSuccess, setUploadMessage }) => {
  const [uploadProgress, setUploadProgress] = useState(0);
  const [uploading, setUploading] = useState(false);

  const onDrop = (acceptedFiles: File[]) => {
    if (acceptedFiles.length > 0) {
      handleUpload(acceptedFiles[0]);
    }
  };

  const { getRootProps, getInputProps } = useDropzone({
    accept: { 'text/csv': ['.csv'] },
    onDrop,
  });

  const handleUpload = async (file: File) => {
    setUploading(true);
    setUploadProgress(0);
    try {
      await uploadProducts(file, (progress) => {
        setUploadProgress(progress);
      });
      // Set the message via the prop function
      setUploadMessage(
        'Upload successful! Your file is being processed. You will be notified when processing is complete.'
      );
      onUploadSuccess();
    } catch (error) {
      console.error('Upload error:', error);
      setUploadMessage('Upload failed.');
    } finally {
      setUploading(false);
    }
  };

  return (
    <div className="mb-8">
      <div {...getRootProps()} className="p-4 border-dashed border-2 border-gray-400 cursor-pointer">
        <input {...getInputProps()} data-testid="file-input" />
        <p>Drag and drop a CSV file here or click to select one</p>
      </div>
      {uploading && (
        <div className="mt-4">
          <progress value={uploadProgress} max={100} className="w-full"></progress>
          <p>Uploading: {uploadProgress}%</p>
        </div>
      )}
    </div>
  );
};

export default CSVUpload;

