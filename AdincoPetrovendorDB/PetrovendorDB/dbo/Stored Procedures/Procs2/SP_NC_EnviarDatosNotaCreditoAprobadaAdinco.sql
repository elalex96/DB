CREATE procedure [dbo].[SP_NC_EnviarDatosNotaCreditoAprobadaAdinco]	
	@IdProveedorPetrovendor INT,
	@IdUsuarioPetrovendor  INT,		    
	@IdNotaCredito INT,
	@IdFacturaAdinco INT,
	@IdFacturaPetrovendor INT,
	@IdUsuarioAdinco INT,
	@IdContrato INT,
	@ComprobantePDFByte IMAGE
    
AS
BEGIN 	

	--ENVIAR GASTOS DE PETROVENDOR A ADINCO
	DECLARE @TotalGastos INT
	DECLARE @IdRegistroAdinco INT
    DECLARE @Contador INT = 1
    DECLARE @IdRegistroPetrovendor INT
    DECLARE @ExitenGastosEnAdinco INT  
	DECLARE @ID_DOCUMENTO INT= 0;
    DECLARE @NOMBRE_EXTENSION NVARCHAR(MAX)
	DECLARE @IdTipoDocumentoAdinco INT = 1  

	CREATE TABLE #GASTOSPETROVENDOR 
    (Id INT,idRegistro INT);



	/*OBTENER LOS GASTOS DE PETROVENDOR RELACIONADOS A LA FACTURA ACTUAL/NOTA DE CREDITO*/
    INSERT INTO #GASTOSPETROVENDOR (Id,idRegistro)
    SELECT  ROW_NUMBER() OVER(ORDER BY GP.IdRegistro ASC) AS Id, GP.IdRegistro
    FROM Petrovendor.dbo.CO_Registro GP
    WHERE GP.IdFactura = @IdFacturaPetrovendor;

    SELECT @TotalGastos = COUNT(Id)
    FROM #GASTOSPETROVENDOR;
		 	
	--SE COPIAN TODOS LOS REGISTROS DE LOS GASTOS CON LOS QUE CUENTA ESTA FACTURA
    WHILE (@Contador <= @TotalGastos )
    BEGIN
        SELECT @IdRegistroPetrovendor = idRegistro
        FROM #GASTOSPETROVENDOR
        WHERE Id = @Contador;

        INSERT INTO Adinco.dbo.CO_Registro
        (
            IdPrograma,
            IdFactura,
            MontoRegistro,
            InicioEjecucion,
            FinEjecucion,
            Comentarios,
            MesPresentacion,
            IdEstado,
            IdUsuarioCreadoPor,
            FecMovto,
            IdInstalacion,
            IdCatalogoCuentasSH,
            Poliza,
            IsEditable,
            CostosAtribuiblesAdministracion,
			PCN,
			IdGastoRubro,
			IdCBSISH,
			IdAceptacionPedidoDetalle
        )
        SELECT GP.IdLineaPresupuestoMes,
               @IdFacturaAdinco,
               GP.MontoRegistro,
               GP.InicioEjecucion,
               GP.FinEjecucion,
               GP.Comentarios,
               GP.MesPresentacion,
               10004,
               @IdUsuarioAdinco,
               GETDATE(),
               GP.IdInstalacion,
               GP.IdCatalogoCuentasSH,
               GP.Poliza,
               1,
               GP.CostosAtribuiblesAdministracion,
			   GP.PCN,
			   GP.IdGastoRubro,
			   GP.IdCBSISH,
			   GP.IdAceptacionPedidoDetalle
        FROM Petrovendor.dbo.CO_Registro GP
        WHERE GP.IdRegistro = @IdRegistroPetrovendor;

		SELECT @IdRegistroAdinco= SCOPE_IDENTITY()
				
         
        INSERT INTO dbo.CO_RelacionRegistroAdinco
        (
            IdRegistroPetrovendor,
            IdRegistroAdinco
        )
        VALUES
        (   @IdRegistroPetrovendor,      -- IdRegistroPetrovendor - int
            @IdRegistroAdinco -- IdRegistroAdinco - int
        );

        SET @Contador =@Contador+ 1;
			

    END;
	

	--REGISTRAR ARCHIVO PDF 
	IF DATALENGTH(@ComprobantePDFByte)>0
	BEGIN 

	 SET @ID_DOCUMENTO = 0;
     SET @NOMBRE_EXTENSION =''
	 SET @IdTipoDocumentoAdinco = 1  --> SELECT * FROM Adinco.dbo.FI_TipoDocumento WHERE id_TipoDocumento=1
			
         -- VALIDAR SI YA EXISTE FACTURA PDF REEMPLAZAR SI NO AGREGAR NUEVA FACTURA 

         SET @ID_DOCUMENTO = ISNULL((SELECT isnull(MAX(IdDocumento),0)
                                     FROM Adinco.dbo.FI_Documento
                                     WHERE IdFactura = @IdFacturaAdinco
                                             AND IdTipoDocumento = @IdTipoDocumentoAdinco --> TIPO DOCUMENTO FACTURA 
											 AND isnull(IsEliminado,0) = 0
                                   ), 0);
         SET @NOMBRE_EXTENSION = 'FI_'+CAST(@IdFacturaAdinco AS NVARCHAR(200))+'.pdf';
         IF(@ID_DOCUMENTO <> 0)
             BEGIN 
                 ---ACTUALIZAR COMPROBANTE ---

                 UPDATE Adinco.dbo.FI_Documento
                   SET                      
                       FechaCarga = GETDATE(),
                       NombreExtensionArchivo = @NOMBRE_EXTENSION,
                       IdUsuario = @IdUsuarioAdinco,
					   DocumentoByte = @ComprobantePDFByte
                 WHERE IdDocumento = @ID_DOCUMENTO
                       AND IdFactura = @IdFacturaAdinco
                       AND IdTipoDocumento = @IdTipoDocumentoAdinco;

					 
		 END;
         ELSE
             BEGIN 
                 ---AGREGAR NUEVO COMPROBANTE ---

                 INSERT INTO Adinco.dbo.FI_Documento
                 (				 
                  IdTipoDocumento,
                  NombreExtensionArchivo,
                  FechaCarga,
                  IdUsuario,
                  IdFactura,
				  DocumentoByte
                 )
                 VALUES
                 (				
                  @IdTipoDocumentoAdinco,
                  @NOMBRE_EXTENSION,
                  GETDATE(),
                  @IdUsuarioAdinco,
                  @IdFacturaAdinco,
				  @ComprobantePDFByte
                 );
				 
             END;

			
	 END 
	
	 
	 SELECT 'SUCCESS'	  
	 
END    

