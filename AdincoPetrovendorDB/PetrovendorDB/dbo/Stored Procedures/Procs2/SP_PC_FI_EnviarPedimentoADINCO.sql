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
-- Author:		<Alexander Gomez>
-- Create date: <01/09/2023>
-- Description:	<se pasa el importe total en el campo de precio unitario para adinco>
-- =============================================
CREATE  PROCEDURE [dbo].[SP_PC_FI_EnviarPedimentoADINCO]
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
               SUM(PCD.ImporteTotal),
               1,
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

		DECLARE @ID_DOCUMENTO_ADINCO INT = (SELECT SCOPE_IDENTITY());

		EXEC dbo.SP_WA_InserRegistroPaseAdinco  @IdPedimentoComprobante,       -- int
		                                        4,       -- int
		                                        @ID_PEDIMENTOCOMPROBANTE_ADINCO, -- int
		                                        @IdUsuario,         -- int
		                                        @IdProveedor,       -- int
		                                        @IdContrato,        -- int
		                                        'PASE DE PEDIMENTO DE IMPORTACION - ENVIO POR SP_PC_FI_EnviarPedimentoADINCO',       -- nvarchar(max)
		                                        '',            -- nvarchar(50)
		                                         0;           -- bit

		 SELECT 'ENVIADO',
		 @ID_PEDIMENTOCOMPROBANTE_ADINCO;

END;


