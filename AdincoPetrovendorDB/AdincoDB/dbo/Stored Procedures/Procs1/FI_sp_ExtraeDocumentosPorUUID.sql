-- Creado Por: Reyna olvera
-- Día: 14/06/2022
-- Extrae los documentos de las facturas apartir de los uuid
----------------------------------------
CREATE PROCEDURE FI_sp_ExtraeDocumentosPorUUID
	@IdUsuario INT = 0,
	@IdContrato INT = 0,
	@UUID VARCHAR(MAX),
	@Tipo VARCHAR(150)
	AS
	BEGIN
		SET NOCOUNT ON;
		CREATE TABLE #UUID(UUID VARCHAR(MAX));

		CREATE TABLE #Temp_UUIDFacturas(
		Id INT IDENTITY(1,1) PRIMARY KEY,
		CFDIAdincoId INT,
		CFDIPetrovendorId INT,
		UUID VARCHAR(150),
		SistemaCartas VARCHAR(150)
		);
		
		CREATE TABLE #Temp_CartasPDF(
		Id INT IDENTITY(1,1) PRIMARY KEY,
		CFDIId int,
		UUID VARCHAR(150),
		Identificador VARCHAR(MAX),
		Carpeta VARCHAR(MAX),
		Ruta VARCHAR(MAX),
		Cubeta  VARCHAR(MAX),
		NombreDocumento VARCHAR(MAX),
		IdDocumento INT,
		);

		INSERT INTO #UUID(UUID)
		SELECT DISTINCT *  from [dbo].[fnSplitString] (@UUID, ',');

		UPDATE #UUID SET UUID = REPLACE(RTRIM(LTRIM(REPLACE(REPLACE(uuid,CHAR (10) ,''),  CHAR (13) ,''))),'	','');

		 --Eliminación de vacios o null para que en el select no se incrementen facturas equivocadas
		DELETE #UUID WHERE UUID IS NULL OR UUID = '';

		INSERT INTO #Temp_UUIDFacturas (CFDIAdincoId,UUID)
		SELECT DISTINCT F.IdFactura,U.UUID
		FROM 
			#UUID U
		JOIN
			FI_FACTURA F
			ON	U.UUID	=	F.UUID COLLATE DATABASE_DEFAULT;
		
		INSERT INTO #Temp_UUIDFacturas (CFDIPetrovendorId,UUID)
		SELECT DISTINCT FP.IdFactura,U.UUID
		FROM 
			#UUID U
		JOIN
				Petrovendor.dbo.FI_Factura FP 
				ON	U.UUID	=	FP.UUID COLLATE DATABASE_DEFAULT
		LEFT JOIN
			#Temp_UUIDFacturas TF
			ON	U.UUID	=	TF.UUID	COLLATE DATABASE_DEFAULT
		WHERE 
			TF.Id IS NULL
			

		IF(@Tipo = 'XML')
		BEGIN
			SELECT  
				UF.CFDIAdincoId AS CFDIId,
				FIAX.ArchivoXml AS xml,
				'XML_'+UF.UUID AS NombreArchivo
			  FROM 
					#Temp_UUIDFacturas UF
			JOIN
				FI_ArchivoXml FIAX
				ON	UF.CFDIAdincoId	=	FIAX.IdFactura
				WHERE	CFDIAdincoId IS NOT NULL
			UNION ALL
			SELECT  
				UF.CFDIPetrovendorId AS CFDIId,
				FIAX.ArchivoXml AS xml,
				'XML_'+UF.UUID AS NombreArchivo
			  FROM 
					#Temp_UUIDFacturas UF
			JOIN
				Petrovendor.dbo.FI_ArchivoXml FIAX
				ON	UF.CFDIPetrovendorId	=	FIAX.IdFactura
				WHERE	CFDIPetrovendorId IS NOT NULL;
		END
		ELSE IF(@Tipo = 'PDF CFDI')
		BEGIN
			SELECT UF.CFDIAdincoId AS CFDIId,
				   Documento=D.DocumentoByte,
				   'PDF_'+UF.UUID AS NombreArchivo
			FROM 
				#Temp_UUIDFacturas UF
			JOIN 
				FI_DOCUMENTO D 
			ON 
				UF.CFDIAdincoId = D.IdFactura 
			AND
				D.IdTipoDocumento = 1
			WHERE	
				CFDIAdincoId IS NOT NULL
		END
		ELSE IF(@Tipo = 'PDF Carta')
		BEGIN
			
		UPDATE U
			SET U.SistemaCartas = 'Petrovendor'
         FROM 
				#Temp_UUIDFacturas U
			JOIN
				Petrovendor.dbo.FI_Factura FP 
				ON	U.UUID	=	FP.UUID COLLATE DATABASE_DEFAULT
              LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura AF ON FP.IdFactura = AF.IdFactura
              LEFT JOIN Petrovendor.dbo.MM_AceptacionCartaPCN AC ON AC.IdAceptacionPedido = AF.IdAceptacionPedido
              LEFT JOIN Petrovendor.dbo.MM_AceptacionPedido AP ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
         WHERE ISNULL(AC.IdEstatus, 0) = 2
               AND ISNULL(AC.IdEstatusEliminado, 0) <> 1
               AND ISNULL(FP.Activa, 0) = 1
               AND ISNULL(FP.IsEliminado, 0) <> 1;

         /**/
		 INSERT INTO #Temp_CartasPDF(CFDIId,UUID,Identificador,Carpeta,Ruta,Cubeta,NombreDocumento,IdDocumento)
                 SELECT AF.IdFactura,
					    'CN_'+FP.UUID,
						D.Identificador , 
                        D.Carpeta , 
                        CONCAT(D.Carpeta, D.Identificador), 
                        ISNULL(D.Bucket,'petrovendor-pr') , 
						CASE 
						WHEN U.CFDIAdincoId IS NOT NULL
						THEN  
							CONCAT('IdFacturaAdinco: ', U.CFDIAdincoId, ' - ', D.NombreDocumento)
						ELSE
							CONCAT('IdFacturaPetrovendor: ', U.CFDIPetrovendorId, ' - ', D.NombreDocumento)
						END  AS NombreArchivo,
						D.IdDocumento
                 FROM 
					#Temp_UUIDFacturas	U
				JOIN
					Petrovendor.dbo.FI_Factura FP
					ON	U.UUID	=	FP.UUID COLLATE DATABASE_DEFAULT
				AND
					U.SistemaCartas	=	'Petrovendor'
                LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura AF ON FP.IdFactura = AF.IdFactura  
                LEFT JOIN Petrovendor.dbo.MM_AceptacionCartaPCN AC ON AC.IdAceptacionPedido = AF.IdAceptacionPedido 
                LEFT JOIN Petrovendor.dbo.MM_AceptacionPedido AP ON AP.IdAceptacionPedido = AC.IdAceptacionPedido  
                LEFT JOIN Petrovendor.dbo.S_Documento_S3 D ON D.IdDocumento = AC.IdDocumento  
                LEFT JOIN Petrovendor.dbo.MM_Pedido P ON P.IdPedido = AP.IdPedido  
                LEFT JOIN Petrovendor.dbo.S_Proveedor PR ON PR.IdProveedor = P.IdSubcontratista 
                WHERE  U.SistemaCartas	=	'Petrovendor'
				AND		ISNULL(AC.IdEstatus, 0) = 2
                AND		ISNULL(AC.IdEstatusEliminado, 0) <> 1
                AND		ISNULL(FP.Activa, 0) = 1
                AND		ISNULL(FP.IsEliminado, 0) = 0;

		 INSERT INTO #Temp_CartasPDF(CFDIId,UUID,Identificador,Carpeta,Ruta,Cubeta,NombreDocumento,IdDocumento)
            SELECT 
				F.IdFactura, 
                'CN_'+F.UUID,
				UPPER(D.UUIDAmazon) , 
                CASE WHEN CHARINDEX('/',D.Folder ) > 0 THEN D.Folder ELSE CONCAT(D.Folder, '/') END, 
                CONCAT(CASE WHEN CHARINDEX('/',D.Folder) > 0 THEN D.Folder ELSE CONCAT(D.Folder, '/') END, D.UUIDAmazon), 
                'adinco', 
                CONCAT('IdFacturaAdinco: ', F.IdFactura, ' - ', D.NombreArchivo) AS NombreArchivo,
				D.AWSDocumentoId
            FROM 
				#Temp_UUIDFacturas	U
			JOIN
				dbo.FI_Factura F
			ON	
				U.CFDIAdincoId	=	F.IdFactura
            JOIN dbo.AWS_DocAwsDocAdinco DA ON F.IdFactura = DA.IdDocAdinco
            JOIN dbo.AWS_Documentos D ON D.AWSDocumentoId = DA.AWSDocumentoId  
            JOIN dbo.PV_Subcontratista S ON S.IdSubcontratista = F.IdSubcontratista  
			WHERE  U.SistemaCartas	IS NULL;

		 SELECT * FROM #Temp_CartasPDF;
		
	END;
END;
