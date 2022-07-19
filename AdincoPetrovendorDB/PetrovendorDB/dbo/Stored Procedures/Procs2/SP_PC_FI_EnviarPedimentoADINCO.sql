USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_PC_FI_EnviarPedimentoADINCO]    Script Date: 19/07/2022 01:41:14 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		DANIEL AC
-- Create date: 28-03-18
-- Description:	ENVIAR PEDIMENTO APROBADO A BASE DE DATOS DE ADINCO 
-- =============================================
-- Author:		<Jose Roman>
-- Update date: <20-11-2018>
-- Description:	<Se agrega el registro de gastos por aceptaciones y se copian a Adinco>
-- Update date: <06-02-2019>
-- Description:	<Se quita el registro de gastos>
-- =============================================
-- Author:		<Alexander Gomez>
-- Update date: <28/10/2019>
-- Description:	<se agrego la bitacora de envio adinco>
-- =============================================

ALTER  PROCEDURE [dbo].[SP_PC_FI_EnviarPedimentoADINCO]
    -- Add the parameters for the stored procedure here
    @IdPedimentoComprobante INT,   
    @IdProveedor INT,
    @IdContrato INT,
    @IdUsuario INT,
	@IdAceptacionPedido INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --BEGIN TRAN tran1;
    --BEGIN TRY

        DECLARE @IdUsuarioAdinco INT = 0;

        SELECT @IdUsuarioAdinco = IdUsuarioADINCO
        FROM dbo.S_Usuario
        WHERE IdUsuario = @IdUsuario;

		
		DECLARE @EXISTE_SUBCONTRATISTA INT 
		DECLARE @IdSubcontratistaExportadorADINCO INT  
		DECLARE @IdSubcontratistaiMPORTARDADINCO INT  

		 DECLARE @IdSubcontratistaImportador INT
	    
	    /*OBTENER EL PROVEEDOR IMPORTADOR EN ADINCO*/
	     
         SELECT @IdSubcontratistaImportador = CC.IdProveedor
         FROM Adinco.dbo.CO_Contrato C
              JOIN Adinco.dbo.CO_Contratista CC ON C.IdContratista = CC.IdContratista
			  LEFT JOIN Petrovendor.dbo.FI_PedimentoComprobante PC ON PC.IdContrato=C.IdContrato
         WHERE PC.IdPedimentoComprobante = @IdPedimentoComprobante

		 /*OBTENER EL SUBCONTRATISTA EXPORTADOR DE PETROVENDOR EN ADINCO */
		SET @EXISTE_SUBCONTRATISTA =(			
			SELECT  COUNT (s.IdSubcontratista)
			FROM Petrovendor.dbo.FI_PedimentoComprobante pc
			INNER JOIN Petrovendor.dbo.S_Proveedor p ON p.IdProveedor=pc.IdSubcontratistaExportador
			INNER JOIN  Adinco.dbo.PV_Subcontratista s ON  ISNULL(s.RFC,'') COLLATE SQL_Latin1_General_CP1_CI_AS = p.RFC 
			WHERE pc.IdPedimentoComprobante=@IdPedimentoComprobante
		)

		IF @EXISTE_SUBCONTRATISTA > 0 		 
		BEGIN 
			---OBTENER EL IDSUBCONTRATISTA ADINCO
				SELECT @IdSubcontratistaExportadorADINCO = S.IdSubcontratista
				FROM Petrovendor.dbo.FI_PedimentoComprobante pc
				INNER JOIN Petrovendor.dbo.S_Proveedor p ON p.IdProveedor=pc.IdSubcontratistaExportador
				INNER JOIN  Adinco.dbo.PV_Subcontratista s ON  ISNULL(s.RFC,'') COLLATE SQL_Latin1_General_CP1_CI_AS = p.RFC 
				WHERE pc.IdPedimentoComprobante=@IdPedimentoComprobante
			END
		ELSE 
		BEGIN 
			--REGISTRAR PROVEEDOR SI NO EXISTE EN ADINCO
			INSERT INTO Adinco.dbo.PV_Subcontratista
			(
			    RFC,
			    RazonSocial,
			    RepresentanteLegal,
			    DiasCreditoID,
			    Giro,
			    PatronalIMSS,
			    TipoPersonaFiscalID,
			    NacionalidadID,					  
			    NombreComercial,
			    CURP,			  
			    RegimenCapital,
			    FechaConstitucion,
			    FechaOperacion,
			    SituacionContribuyente,
			    FechaCambioSituacion,
			    Pais,
			    Entidad,
			    Municipio,
			    Colonia,
			    TipoVialidad,
			    NombreVialidad,
			    NumExterior,
			    NumInterior,
			    CodigoPostal,
			    IsEliminado,			    
			    IdPetroVendor			   
			)

			SELECT 
			p.RFC,
			p.RazonSocial,
			'' AS RepresentanteLegal,--
			P.DiasCredito, --
			'' AS Giro, --
			'' AS PatronalIMSS,---
			(CASE WHEN p.IdTipoRegimen = 1 THEN  --1 MORAL EN PETROVENDOR
				 2 --MORAL EN ADINCO
			WHEN  P.IdTipoRegimen = 2 THEN --2 FISICA EN PETROVENDOR 
				1  -- FISICA EN ADINCO
			WHEN P.IdTipoRegimen =3 THEN  --3 MORAL FISICA EXTRANJERA
				3 --3 MORAL FISICA ADINCO
			ELSE 
				3 --3 MORAL FISICA ADINCO
			END )AS IdTipoRegimen,
			P.IdNacionalidad,
			p.Alias,
			p.CURP,
			P.RegimenCapital,
			P.FechaConstitucion,
			P.FechaOperacion,
			P.SituacionContribuyente,	
			P.FechaCambioSituacion,		
			P.Pais,
			P.Entidad,
			P.Municipio,
			P.Colonia,
			P.TipoVialidad,
			P.NombreVialidad,
			P.NumExterior,
			P.NumInterior,
			P.CodigoPostal,
			p.IsEliminado,
			P.IdProveedor
			FROM Petrovendor.dbo.FI_PedimentoComprobante pc
			INNER JOIN Petrovendor.dbo.S_Proveedor p ON p.IdProveedor=pc.IdSubcontratistaExportador
			WHERE pc.IdPedimentoComprobante=@IdPedimentoComprobante		

			SET @IdSubcontratistaExportadorADINCO = (SELECT SCOPE_IDENTITY())

		END 		

		/*AGREGAR PEDIMENTO CABECERA*/
        INSERT INTO Adinco.dbo.FI_PedimentoComprobante
        (
            IdContrato,
            NumeroPedimento,
            ClavePedimento,
            FolioComprobante,
            FechaPago,
            Regimen,
            AduanaES,
            IdMoneda,
            AcuseElectronico,
            CvTipoDocFacturacion,
            ProcesadoSIPAC,
            CreadoPor,
            CreadoEn,
            Activo,
            IdOrigen,
            IdPedimentoComprobantePetrovendor,
            FechaIntercambio,
			IdSubcontratistaExportador,
			IdSubcontratistaImportador
        )
        SELECT PC.IdContrato,
               PC.NumeroPedimento,
               PC.ClavePedimento,
               PC.FolioComprobante,
               PC.FechaPago,
               PC.Regimen,
               PC.AduanaES,
               PC.IdMoneda,
               PC.AcuseElectronico,
               PC.CvTipoDocFacturacion,
               PC.ProcesadoSIPAC,         -- 0
               @IdUsuarioAdinco,          -- CreadoPor
               GETDATE(),                 ---CreadoEn
               1,                         ---Activo
               1,                         ---IdOrigen -->Petrovendor 
               PC.IdPedimentoComprobante, ---IdPedimentoComprobantePetrovendor
               GETDATE(),                  ---GETDATE()	
			   @IdSubcontratistaExportadorADINCO,
			   @IdSubcontratistaImportador
        FROM Petrovendor.dbo.FI_PedimentoComprobante PC
        WHERE PC.IdPedimentoComprobante = @IdPedimentoComprobante;

        DECLARE @ID_PEDIMENTOCOMPROBANTE_ADINCO INT = (
                                                          SELECT SCOPE_IDENTITY()
                                                      );

		/*AGREGAR PEDIMENTO DETALLE*/
        INSERT INTO Adinco.dbo.FI_PedimentoComprobanteDetalle
        (
            IdPedimentoComprobante,
            IdUnidadMedida,
            NumeroSerieMercancia,
            DescripcionMercancia,
            ClaseBienServicio,
            PrecioUnitario,
            Cantidad,
            ImporteTotal,
            CreadoPor,
            CreadoEn
        )
        SELECT @ID_PEDIMENTOCOMPROBANTE_ADINCO,
               (SELECT TOP 1 IdUnidadMedida FROM Petrovendor.dbo.FI_PedimentoComprobanteDetalle WHERE IdPedimentoComprobante = @IdPedimentoComprobante),
               '-',
               '-',
               '-',
               SUM(PCD.PrecioUnitario),
               SUM(PCD.Cantidad),
               SUM(PCD.ImporteTotal),
               @IdUsuarioAdinco,
               GETDATE()
        FROM Petrovendor.dbo.FI_PedimentoComprobanteDetalle AS PCD
        WHERE IdPedimentoComprobante = @IdPedimentoComprobante
              AND IsActivo = 1
		GROUP BY IdPedimentoComprobante;

	    /*AGREGAR DOCUMENTO PEDIMENTO*/
        INSERT INTO Adinco.dbo.FI_Documento
        (
            IdTipoDocumento,
            IdPedimentoComprobante,
            NombreExtensionArchivo,
            IdUsuario,
            FechaCarga,
            IsEliminado,
            DocumentoByte
        )

        SELECT IdTipoDocumento,
               @ID_PEDIMENTOCOMPROBANTE_ADINCO,
               NombreExtensionArchivo,
               @IdUsuarioAdinco,
               GETDATE(),
               IsEliminado,
               DocumentoByte
        FROM Petrovendor.dbo.FI_Documento
        WHERE IdPedimentoComprobante = @IdPedimentoComprobante
              AND IsEliminado = 0;

		DECLARE @ID_DOCUMENTO_ADINCO INT = (SELECT SCOPE_IDENTITY())

		EXEC dbo.SP_WA_InserRegistroPaseAdinco  @IdPedimentoComprobante,       -- int
		                                        4,       -- int
		                                        @ID_PEDIMENTOCOMPROBANTE_ADINCO, -- int
		                                        @IdUsuario,         -- int
		                                        @IdProveedor,       -- int
		                                        @IdContrato,        -- int
		                                        'PASE DE PEDIMENTO DE IMPORTACION - ENVIO POR SP_PC_FI_EnviarPedimentoADINCO',       -- nvarchar(max)
		                                        '',            -- nvarchar(50)
		                                         0;           -- bit
		

		------------------- Registro de gasto en petrovendor ------------------------------------------
		--IF(@IdAceptacionPedido > 0)
		--BEGIN
		--	INSERT INTO dbo.CO_Registro
		--	(
		--		IdPrograma,
		--		IdFactura,
		--		MontoRegistro,
		--		InicioEjecucion,
		--		FinEjecucion,
		--		Comentarios,
		--		MesPresentacion,
		--		IdEstado,
		--		IdUsuarioCreadoPor,
		--		FecMovto,
		--		IdInstalacion,
		--		CreadoPor,
		--		IdPedimentoComprobante,
		--		CvTipoDocFacturacion,
		--		CentroCostos,
		--		IdLineaPresupuestoMes,
		--		CostosAtribuiblesAdministracion,
		--		IdGastoRubro,
		--		PCN,
		--		IdCBSISH,
		--		IdAceptacionPedidoDetalle
		--	)
		--	SELECT spdlp.IdLineaPresupuesto,
		--		NULL,
		--		(apd.Cantidad * pod.PrecioUnitario),
		--		p.FechaRecepcionServicio,
		--		ap.Creado,
		--		CONCAT(POD.MaterialCotizadoTextoC, ' - ', i.NombreInstalacion COLLATE Modern_Spanish_CI_AS),
		--		DATEADD(MONTH, DATEDIFF(MONTH, 0, p.FechaRecepcionServicio), 0),
		--		10000,
		--		@IdUsuario,
		--		GETDATE(),
		--		spdlp.IdInstalacion,
		--		@IdUsuario,
		--		@IdPedimentoComprobante,
		--		3,
		--		spdlp.IdCentroCosto,
		--		spdlp.IdLineaPresupuesto,
		--		0,
		--		apd.ClasificacionCN,
		--		apd.PCN,
		--		vp.IdCatalogoHidrocarburos,
		--		apd.IdAceptacionPedidoDetalle
		--	FROM dbo.MM_AceptacionPedidoDetalle apd 
		--	INNER JOIN dbo.MM_PedidoDetalle pd ON pd.IdPedidoDetalle = apd.IdPedidoDetalle
		--	INNER JOIN dbo.MM_PeticionOfertaDetalle pod ON pod.IdPeticionOfertaDetalle = pd.IdPeticionOfertaDetalle
		--	INNER JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdlp ON spdlp.IdSolicitudPedidoDetalle = pod.IdSolicitudPedidoDetalle 
		--	INNER JOIN dbo.MM_Pedido p ON p.IdPedido = pd.IdPedido
		--	INNER JOIN dbo.MM_AceptacionPedido ap ON ap.IdAceptacionPedido = apd.IdAceptacionPedido
		--	INNER JOIN Adinco.dbo.CO_Instalacion i ON i.IdInstalacion = spdlp.IdInstalacion
		--	LEFT JOIN MM_PCN_ValoresPesos vp ON vp.IdAceptacionPedidoDetalle = apd.IdAceptacionPedidoDetalle
		--	WHERE apd.IdAceptacionPedido = @IdAceptacionPedido

		--	--Copia del gasto a la bd de Adinco
		--	INSERT INTO Adinco.dbo.CO_Registro
		--	(
		--		IdPrograma,
		--		IdFactura,
		--		MontoRegistro,
		--		InicioEjecucion,
		--		FinEjecucion,
		--		Comentarios,
		--		MesPresentacion,
		--		IdEstado,
		--		IdUsuarioCreadoPor,
		--		IdUsuarioModPor,
		--		FecMovto,
		--		IdInstalacion,
		--		CreadoPor,
		--		Fila,
		--		IdPedimentoComprobante,
		--		CvTipoDocFacturacion,
		--		IdCatalogoCuentasSH,
		--		Poliza,
		--		IsEditable,
		--		CostosAtribuiblesAdministracion,
		--		IdGastoRubro,
		--		PCN,
		--		IdCBSISH
		--	)
		--	SELECT rp.IdPrograma,
		--	rp.IdFactura,
		--	rp.MontoRegistro,
		--	rp.InicioEjecucion,
		--	rp.FinEjecucion,
		--	rp.Comentarios,
		--	rp.MesPresentacion,
		--	rp.IdEstado,
		--	@IdUsuarioAdinco,
		--	rp.IdUsuarioModPor,
		--	rp.FecMovto,
		--	rp.IdInstalacion,
		--	@IdUsuarioAdinco,
		--	rp.Fila,
		--	@ID_PEDIMENTOCOMPROBANTE_ADINCO,
		--	rp.CvTipoDocFacturacion,
		--	rp.IdCatalogoCuentasSH,
		--	rp.Poliza,
		--	1,
		--	rp.CostosAtribuiblesAdministracion,
		--	rp.IdGastoRubro,
		--	rp.PCN,
		--	rp.IdCBSISH
		--	FROM dbo.CO_Registro rp
		--	WHERE rp.IdAceptacionPedidoDetalle 

		--	INSERT INTO dbo.CO_RelacionRegistroAdinco
		--	(
		--		IdRegistroPetrovendor,
		--		IdRegistroAdinco
		--	)
		--	SELECT rp.IdRegistro,
		--		ra.IdRegistro
		--	FROM dbo.CO_Registro rp
		--	INNER JOIN Adinco.dbo.CO_Registro ra ON ra.IdAceptacionPedidoDetalle = rp.IdAceptacionPedidoDetalle
		--	WHERE rp.IdPedimentoComprobante = @IdPedimentoComprobante
		--END
		
        --COMMIT TRAN tran1;
		 SELECT 'ENVIADO',
		 @ID_PEDIMENTOCOMPROBANTE_ADINCO

    --END TRY
    --BEGIN CATCH
    --    ROLLBACK TRAN tran1;
    --    SELECT 'ERROR_PROCESO',
    --           ERROR_NUMBER() AS ErrorNumber,
    --           ERROR_SEVERITY() AS ErrorSeverity,
    --           ERROR_STATE() AS ErrorState,
    --           ERROR_PROCEDURE() AS ErrorProcedure,
    --           ERROR_LINE() AS ErrorLine,
    --           ERROR_MESSAGE() AS ErrorMessage;
    --END CATCH;

END;


