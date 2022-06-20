USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_PC_FI_EnviarComprobanteADINCO'
)
    DROP PROCEDURE SP_PC_FI_EnviarComprobanteADINCO;
	GO
/****** Object:  StoredProcedure [dbo].[SP_PC_FI_EnviarComprobanteADINCO]    Script Date: 19/06/2022 11:41:01 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 06/06/2020
-- Description:	se agrega la validacion de las unidad entre la db de adinco y petro para evitar errores de fk
-- =============================================
-- =============================================
-- Author:		DANIEL AC
-- Create date: 11-02-21
-- Description:	VALIDACION DE NO ENVIAR DOBLE PEDIMENTO
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 20-06-2021
-- Description:	Se agrega validacion para ver si se envia o no el PCN 
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_FI_EnviarComprobanteADINCO]
    -- Add the parameters for the stored procedure here

    @IdPedimentoComprobante INT,   
    @IdProveedor INT,
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
        DECLARE @ID_PEDIMENTOCOMPROBANTE_ADINCO INT
        DECLARE @IdUsuarioAdinco INT = 0;
		DECLARE @IdPedimentoComprobanteAdinco INT = 0;
		DECLARE @IdPedidoGral INT=0, @IdAceptacionPedido INT =0
        SELECT @IdUsuarioAdinco = IdUsuarioADINCO
        FROM dbo.S_Usuario
        WHERE IdUsuario = @IdUsuario;

		DECLARE @NOMBRE_UNIDAD NVARCHAR(MAX); 
		DECLARE @NID_UNIDAD INT; 
		DECLARE @NID_UNIDADADINCO INT;
		DECLARE @EXISTE_SUBCONTRATISTA INT 
		DECLARE @IdSubcontratistaExportadorADINCO INT  
		DECLARE @IdSubcontratistaiMPORTARDADINCO INT  

		DECLARE @IdSubcontratistaImportador INT
		DECLARE @IncluyePCN BIT = 1
	
	    
	    /*OBTENER EL PROVEEDOR IMPORTADOR EN ADINCO*/
	     
         SELECT @IdSubcontratistaImportador = CC.IdProveedor
         FROM Adinco.dbo.CO_Contrato C
              JOIN Adinco.dbo.CO_Contratista CC 
				ON C.IdContratista = CC.IdContratista
			  LEFT JOIN Petrovendor.dbo.FI_PedimentoComprobante PC 
				ON C.IdContrato = PC.IdContrato
         WHERE PC.IdPedimentoComprobante = @IdPedimentoComprobante

		 /*OBTENER EL SUBCONTRATISTA EXPORTADOR DE PETROVENDOR EN ADINCO */
		SET @EXISTE_SUBCONTRATISTA =(			
			SELECT  COUNT (s.IdSubcontratista)
			FROM Petrovendor.dbo.FI_PedimentoComprobante pc
			JOIN Petrovendor.dbo.S_Proveedor p 
				ON pc.IdSubcontratistaExportador = p.IdProveedor
			JOIN  Adinco.dbo.PV_Subcontratista s 
				ON  p.RFC  = ISNULL(s.RFC,'') COLLATE SQL_Latin1_General_CP1_CI_AS 
			WHERE pc.IdPedimentoComprobante=@IdPedimentoComprobante
		)

		IF @EXISTE_SUBCONTRATISTA > 0 		 
		BEGIN 
			---OBTENER EL IDSUBCONTRATISTA ADINCO
				SELECT @IdSubcontratistaExportadorADINCO = S.IdSubcontratista
				FROM Petrovendor.dbo.FI_PedimentoComprobante pc
				JOIN Petrovendor.dbo.S_Proveedor p 
					ON pc.IdSubcontratistaExportador = p.IdProveedor
				JOIN  Adinco.dbo.PV_Subcontratista s 
					ON p.RFC  =  ISNULL(s.RFC,'') COLLATE SQL_Latin1_General_CP1_CI_AS 
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
			JOIN Petrovendor.dbo.S_Proveedor p 
				ON pc.IdSubcontratistaExportador = p.IdProveedor
			WHERE pc.IdPedimentoComprobante=@IdPedimentoComprobante		

			SET @IdSubcontratistaExportadorADINCO = (SELECT SCOPE_IDENTITY())

		END
		
		/*SE VALIDA LA UNIDAD PARA EVITAR ERRORES CON LA DB DE ADINCO*/
		SELECT 
			@NID_UNIDAD  = PCD.IdUnidadMedida,
			@NOMBRE_UNIDAD = UN.Unidad
        FROM Petrovendor.dbo.FI_PedimentoComprobanteDetalle AS PCD
			LEFT JOIN dbo.PV_MM_MaterialUnidad AS UN 
				ON PCD.IdUnidadMedida = UN.IdUnidad
        WHERE IdPedimentoComprobante = @IdPedimentoComprobante
              AND PCD.IsActivo = 1;

		/*SE BUSCA LA UNIDAD CON EL NOMBRE IGUAL EN ADINCO*/
		SELECT
			@NID_UNIDADADINCO = UNA.IdUnidad
		FROM Adinco.dbo.PV_MM_MaterialUnidad AS UNA
		WHERE UNA.Unidad = @NOMBRE_UNIDAD;

		/*SE VALIDA QUE EXISTA SI NO EXISTE SE INSERTA, SI EXISTE SIMPLEMENTE SE ASIGNA LA VARIABLE LLENADA ANTERIORMENTE*/
		IF @NID_UNIDADADINCO IS NULL
		BEGIN
		    
			INSERT INTO Adinco.dbo.PV_MM_MaterialUnidad
			(
			    Unidad,
			    UMB,
			    IsActivo,
			    IsEliminado,
			    CreadoPor,
			    CreadoEn,
			    ModificadoPor,
			    ModificadoEn
			)
			SELECT
				UNP.Unidad,
				UNP.UMB,
				1,
				NULL,
				UNP.CreadoPor,
				GETDATE(),
				UNP.ModificadoPor,
				UNP.ModificadoEn
			FROM Petrovendor.dbo.PV_MM_MaterialUnidad AS UNP
			WHERE UNP.IdUnidad = @NID_UNIDAD;

			SET @NID_UNIDADADINCO = SCOPE_IDENTITY();

		END; 
						
		
		/*VALIDAR SI EL PEDIMENTO COMPROBANTE DE PETROVENDOR YA ESTA EN ADINCO, SI, YA ESTA, NO ENVIAR PEDIMENTO*/	 

		SELECT @ID_PEDIMENTOCOMPROBANTE_ADINCO=IdPedimentoComprobante
		FROM Adinco.dbo.FI_PedimentoComprobante
		WHERE IdPedimentoComprobantePetrovendor=@IdPedimentoComprobante
				
        IF ISNULL(@ID_PEDIMENTOCOMPROBANTE_ADINCO,0)=0
		BEGIN
		/*AGREGAR COMPROBANTE CABECERA*/
        INSERT INTO Adinco.dbo.FI_PedimentoComprobante
        (
            IdContrato,
            FolioComprobante,
            FechaPago,
			IdSubcontratistaImportador,
			IdSubcontratistaExportador,			
			IdFormaPago,
			IdMoneda,
            CvTipoDocFacturacion,
            ProcesadoSIPAC,
            CreadoPor,
            CreadoEn,
            Activo,
            IdOrigen,
            IdPedimentoComprobantePetrovendor,
            FechaIntercambio,
			HashSHA256	
        )
        SELECT PC.IdContrato,
               PC.FolioComprobante,
               PC.FechaPago,
			   @IdSubcontratistaImportador,
			   @IdSubcontratistaExportadorADINCO,	
			   PC.IdFormaPago,	
			   PC.IdMoneda,	
               PC.CvTipoDocFacturacion,
               PC.ProcesadoSIPAC,         -- 0
               @IdUsuarioAdinco,          -- CreadoPor
               GETDATE(),                 ---CreadoEn
               1,                         ---Activo
               1,                         ---IdOrigen -->Petrovendor 
               PC.IdPedimentoComprobante, ---IdPedimentoComprobantePetrovendor
               GETDATE(),                  ---GETDATE()	
			   PC.HashSHA256			   
        FROM Petrovendor.dbo.FI_PedimentoComprobante PC
        WHERE PC.IdPedimentoComprobante = @IdPedimentoComprobante;


        SET @ID_PEDIMENTOCOMPROBANTE_ADINCO  = (SELECT SCOPE_IDENTITY());

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
               @NID_UNIDADADINCO,
               PCD.NumeroSerieMercancia,
               PCD.DescripcionMercancia,
               PCD.ClaseBienServicio,
               PCD.PrecioUnitario,
               PCD.Cantidad,
               PCD.ImporteTotal,
               @IdUsuarioAdinco,
               GETDATE()
        FROM Petrovendor.dbo.FI_PedimentoComprobanteDetalle AS PCD
        WHERE IdPedimentoComprobante = @IdPedimentoComprobante
              AND IsActivo = 1;


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

		-----------------REGISTRO DEL GASTO---------------------

		
		SELECT @IdPedidoGral =IdPedido,
		@IdAceptacionPedido = IdAceptacionPedido
		FROM dbo.FI_AceptacionPedido_PedimentoComprobante 
		WHERE IdPedimentoComprobante = @IdPedimentoComprobante

		SELECT @IncluyePCN=PedirCarta
		FROM RelacionCartaCNPedido 
		WHERE IdAceptacionPedido=@IdAceptacionPedido

		IF(ISNULL(@IdPedidoGral,0) > 0)
		BEGIN
			--Si el comprobante es de mercadeo
		    INSERT INTO dbo.CO_Registro
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
				CreadoPor,
				IdPedimentoComprobante,
				CvTipoDocFacturacion,
				CentroCostos,
				IdLineaPresupuestoMes,
				CostosAtribuiblesAdministracion,
				IdGastoRubro,
				PCN,
				IdCBSISH,
				IdAceptacionPedidoDetalle
			)
			SELECT APDI.IdLineaPresupuesto,
				NULL,
				(APDI.Cantidad * pd.PrecioUnitario),
				p.FechaRecepcionServicio,
				ap.Creado,
				CONCAT(POD.MaterialCotizadoTextoC, ' - ', i.NombreInstalacion COLLATE Modern_Spanish_CI_AS),
				DATEADD(MONTH, DATEDIFF(MONTH, 0, p.FechaRecepcionServicio), 0),
				10004,
				@IdUsuario,
				GETDATE(),
				APDI.IdInstalacion,
				@IdUsuario,
				@IdPedimentoComprobante,
				3,
				spdlp.IdCentroCosto,
				APDI.IdLineaPresupuesto,
				0,
				apd.ClasificacionCN,
				CASE WHEN ISNULL(@IncluyePCN,0)=1 THEN 
					apd.PCN
				ELSE 
					NULL
				END,
				vp.IdCatalogoHidrocarburos,
				apd.IdAceptacionPedidoDetalle
			FROM dbo.FI_PedimentoComprobante pc
			JOIN dbo.FI_AceptacionPedido_PedimentoComprobante apc 
				ON pc.IdPedimentoComprobante = apc.IdPedimentoComprobante 
			JOIN dbo.MM_AceptacionPedidoDetalle apd 
				ON apc.IdAceptacionPedido = apd.IdAceptacionPedido  
			JOIN dbo.MM_PedidoDetalle pd 
				ON apd.IdPedidoDetalle = pd.IdPedidoDetalle 
			JOIN dbo.MM_PeticionOfertaDetalle pod 
				ON pd.IdPeticionOfertaDetalle = pod.IdPeticionOfertaDetalle 
			JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdlp 
				ON pod.IdSolicitudPedidoDetalle = spdlp.IdSolicitudPedidoDetalle 
			JOIN dbo.MM_Pedido p 
				ON  pd.IdPedido = p.IdPedido 
			JOIN dbo.MM_AceptacionPedido ap 
				ON apd.IdAceptacionPedido = ap.IdAceptacionPedido 
			LEFT JOIN dbo.MM_AceptacionPedidoDetalleInstalacion AS APDI 
				ON  apd.IdAceptacionPedidoDetalle = APDI.IdAceptacionPedidoDetalle 
			INNER JOIN Adinco.dbo.CO_Instalacion i 
				ON  APDI.IdInstalacion = i.IdInstalacion 
			LEFT JOIN MM_PCN_ValoresPesos vp 
				ON  apd.IdAceptacionPedidoDetalle = vp.IdAceptacionPedidoDetalle 
			WHERE pc.IdPedimentoComprobante = @IdPedimentoComprobante;
		END
		ELSE
		BEGIN
			--Si el comprobante es por compra directa
		    INSERT INTO dbo.CO_Registro
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
				CreadoPor,
				IdPedimentoComprobante,
				CvTipoDocFacturacion,
				CentroCostos,
				IdLineaPresupuestoMes,
				CostosAtribuiblesAdministracion,
				IdGastoRubro,
				PCN,
				IdCBSISH,
				IdAceptacionPedidoDetalle
			)
			SELECT 
				NULL,
				NULL,
				pcd.ImporteTotal,
				pc.FechaPago,
				pc.FechaPago,
				NULL,
				DATEADD(MONTH, DATEDIFF(MONTH, 0, pc.CreadoEn), 0),
				10004,
				@IdUsuario,
				GETDATE(),
				NULL,
				@IdUsuario,
				@IdPedimentoComprobante,
				3,
				NULL,
				NULL,
				0,
				NULL,
				0,
				NULL,
				pcd.IdAceptacionPedidoDetalle
			FROM dbo.FI_PedimentoComprobante pc
			JOIN dbo.FI_PedimentoComprobanteDetalle pcd 
				ON pc.IdPedimentoComprobante = pcd.IdPedimentoComprobante 
			WHERE pc.IdPedimentoComprobante = @IdPedimentoComprobante
		END

		--se copia a CO_Registro de Adinco
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
		    IdUsuarioModPor,
		    FecMovto,
		    IdInstalacion,
		    CreadoPor,
		    Fila,
		    IdPedimentoComprobante,
		    CvTipoDocFacturacion,
		    IdCatalogoCuentasSH,
		    Poliza,
		    CostosAtribuiblesAdministracion,
		    IdGastoRubro,
		    PCN,
		    IdCBSISH,
		    IdAceptacionPedidoDetalle
		)
		SELECT 
			r.IdPrograma,
			r.IdFactura,
			r.MontoRegistro,
			r.InicioEjecucion,
			r.FinEjecucion,
			r.Comentarios,
			r.MesPresentacion,
			r.IdEstado,
			ISNULL(u.IdUsuarioADINCO, u.IdUsuario),
			ISNULL(u.IdUsuarioADINCO, u.IdUsuario),
			r.FecMovto,
			r.IdInstalacion,
			ISNULL(u.IdUsuarioADINCO, u.IdUsuario),
			r.Fila,
			@ID_PEDIMENTOCOMPROBANTE_ADINCO,
			r.CvTipoDocFacturacion,
			r.IdCatalogoCuentasSH,
			r.Poliza,
			r.CostosAtribuiblesAdministracion,
			r.IdGastoRubro,
			r.PCN,
			r.IdCBSISH,
			r.IdAceptacionPedidoDetalle
		FROM dbo.CO_Registro r
		LEFT JOIN dbo.S_Usuario u 
			ON  r.CreadoPor = u.IdUsuario 
		WHERE r.IdPedimentoComprobante = @IdPedimentoComprobante
		
		--Se agrega la relacion de comprobante Petrovendor/Adinco
        INSERT INTO dbo.FI_RelacionComprobanteAdinco
        (
            IdComprobantePetrovendor,
            IdComprobanteAdinco,
            FechaEnvio
        )
        VALUES
        (   @IdPedimentoComprobante,        -- IdComprobantePetrovendor - int
            @ID_PEDIMENTOCOMPROBANTE_ADINCO,        -- IdComprobanteAdinco - int
            GETDATE() -- FechaEnvio - datetime
        )

		EXEC dbo.SP_WA_InserRegistroPaseAdinco  @IdPedimentoComprobante,       -- int
		                                        3,       -- int
		                                        @ID_PEDIMENTOCOMPROBANTE_ADINCO, -- int
		                                        @IdUsuario,         -- int
		                                        @IdProveedor,       -- int
		                                        @IdContrato,        -- int
		                                        'PASE DE COMPROBANTE EXTRANJEROO - ENVIO POR SP_PC_FI_EnviarComprobanteADINCO',       -- nvarchar(max)
		                                        '',            -- nvarchar(50)
		                                         0;           -- bit
		


		END 

		

		SELECT 'ENVIADO',
		@ID_PEDIMENTOCOMPROBANTE_ADINCO

END;

