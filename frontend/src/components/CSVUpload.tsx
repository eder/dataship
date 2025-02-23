import React, { useState } from 'react';
import { useDropzone } from 'react-dropzone';
import { uploadProducts } from '../api/products';

interface CSVUploadProps {
  onUploadSuccess: () => void;
}

const CSVUpload: React.FC<CSVUploadProps> = ({ onUploadSuccess }) => {
  const [uploadProgress, setUploadProgress] = useState(0);
  const [uploading, setUploading] = useState(false);
  const [message, setMessage] = useState('');

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
      setMessage('Upload successful!');
      onUploadSuccess();
    } catch (error) {
      console.error('upload error:', error);
      setMessage('upload error.');
    } finally {
      setUploading(false);
    }
  };

  return (
    <div className="mb-8">
      <div {...getRootProps()} className="p-4 border-dashed border-2 border-gray-400 cursor-pointer">
        <input {...getInputProps()} />
        <p>Drag and drop a CSV file here or click to select</p>
      </div>
      {uploading && (
        <div className="mt-4">
          <progress value={uploadProgress} max={100} className="w-full"></progress>
          <p>Sending: {uploadProgress}%</p>
        </div>
      )}
      {message && <p className="mt-4 text-green-600">{message}</p>}
    </div>
  );
};

export default CSVUpload;
