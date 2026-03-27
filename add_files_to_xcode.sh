#!/bin/bash

# Script para adicionar arquivos ao projeto Xcode
# Usage: ./add_files_to_xcode.sh

cd "/Users/lucas/Desktop/Projetos Coding/KebabLocator-iOS"

# Adicionar ReportPlaceView
xcodebuild -project KebabLocator.xcodeproj -target KebabLocator -add-file "KebabLocator/Views/ReportPlaceView.swift" 2>/dev/null || echo "ReportPlaceView já existe ou não foi possível adicionar"

# Adicionar SubmitVerificationView  
xcodebuild -project KebabLocator.xcodeproj -target KebabLocator -add-file "KebabLocator/Views/SubmitVerificationView.swift" 2>/dev/null || echo "SubmitVerificationView já existe ou não foi possível adicionar"

echo "Arquivos adicionados. Tente fazer build no Xcode."
