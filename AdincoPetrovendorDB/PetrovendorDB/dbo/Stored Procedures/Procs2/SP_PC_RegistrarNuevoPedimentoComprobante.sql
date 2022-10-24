USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_PC_RegistrarNuevoPedimentoComprobante]    Script Date: 20/10/2022 12:22:15 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		DANIEL AC
-- Create date: 27-03-18
-- Description:	Registrar un nuevo pedimento comprobante 
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 12/11/2019
-- Description:	modificacion del agregado de los  detalles del pedimento comprobante desde la aceptacion
-- =============================================
ALTER PROCEDURE [dbo].[SP_PC_RegistrarNuevoPedimentoComprobante]
    -- Add the parameters for the stored procedure here

    @IdProveedor INT,
    @IdContrato INT,
    @IdUsuario INT,
    @IdAceptacionPedido INT,
    @CvTipoDocFacturacion INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @ExisteRegistro INT = 0;

    SELECT @ExisteRegistro = COUNT(PC.IdPedimentoComprobante)
    FROM dbo.FI_PedimentoComprobante PC
        INNER JOIN dbo.FI_AceptacionPedido_PedimentoComprobante AS AP_PC
            ON AP_PC.IdPedimentoComprobante = PC.IdPedimentoComprobante
        INNER JOIN dbo.MM_AceptacionPedido AP
            ON AP.IdAceptacionPedido = AP_PC.IdAceptacionPedido
    WHERE AP.IdAceptacionPedido = @IdAceptacionPedido;

    IF @ExisteRegistro = 0
    BEGIN

        DECLARE @ID_CONTRATO INT = 0;
        DECLARE @ID_PROVEEDOR_IMPORTADOR INT = 0;
		DECLARE @ID_PEDIDO INT= 0

        SELECT @ID_CONTRATO = P.IdContrato,
               @ID_PROVEEDOR_IMPORTADOR = P.IdProveedorCompras,
			   @ID_PEDIDO = P.IdPedido
        FROM dbo.MM_Pedido P
            INNER JOIN dbo.MM_AceptacionPedido AP
                ON P.IdPedido = AP.IdPedido
        WHERE AP.IdAceptacionPedido = @IdAceptacionPedido;


        INSERT INTO dbo.FI_PedimentoComprobante
        (
            IdContrato,
            IdSubcontratistaImportador,
            IdSubcontratistaExportador,
            CvTipoDocFacturacion,
            CreadoPor,
            CreadoEn,
            IsEliminado,
            IsActivo,
            IsBorrador,
			TipoOrigen
        )
        VALUES
        (   @ID_CONTRATO,             -- IdContrato - int 
            @ID_PROVEEDOR_IMPORTADOR, -- IdSubcontratistaImportador - int			   
            @IdProveedor,             -- IdSubcontratistaExportador - int			   
            @CvTipoDocFacturacion,    -- CvTipoDocFacturacion - int			    
            @IdUsuario,               -- CreadoPor - int
            GETDATE(),                -- CreadoEn - datetime			  
            0,                        -- IsEliminado - bit
            1,                        -- IsActivo - bit
            1,                        -- IsBorrador - bit
			'PC_M'					  -- PC_M --> PEDIMENTO COMPROBANTE MERCADEO
            );

		DECLARE @ID_PEDIMENTOCOMPROBANTE INT; 
		SET @ID_PEDIMENTOCOMPROBANTE = (SCOPE_IDENTITY());

		INSERT INTO dbo.FI_PedimentoComprobanteDetalle
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
		    CreadoEn,
		    ModificadoPor,
		    ModificadoEn,
		    IsEliminado,
		    IsActivo,
		    IsBorrador,
		    IdAceptacionPedido,
		    IdMaterialImportado,
		    IdAceptacionPedidoDetalle
		)
		SELECT
			@ID_PEDIMENTOCOMPROBANTE,
			PD.IdUnidadProveedor,
			NULL,
			POD.MaterialCotizadoTextoC,
			NULL,
			ISNULL(APD.PrecioUnitario,PD.PrecioUnitario),
			APD.Cantidad,
			(APD.Cantidad * ISNULL(APD.PrecioUnitario,PD.PrecioUnitario)),
			@IdUsuario,
			GETDATE(),
			NULL,
			NULL,
			NULL,
			1,
			NULL,
			APD.IdAceptacionPedido,
			PD.IdMaterialVendedor,
			APD.IdAceptacionPedidoDetalle
		FROM dbo.MM_AceptacionPedidoDetalle AS APD
			LEFT JOIN dbo.MM_PedidoDetalle AS PD ON PD.IdPedidoDetalle = APD.IdPedidoDetalle
			LEFT JOIN dbo.MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle
		WHERE IdAceptacionPedido = @IdAceptacionPedido;


		INSERT INTO dbo.FI_AceptacionPedido_PedimentoComprobante
		(
		    IdAceptacionPedido,
		    IdPedimentoComprobante,
		    NoVersion,
		    IdPedido,
		    CreadoEl,
		    CreadoPor,		   
		    Activo
		)
		VALUES
		(   @IdAceptacionPedido,         -- IdAceptacionPedido - int
		    @ID_PEDIMENTOCOMPROBANTE,         -- IdPedimentoComprobante - int
		    1,         -- NoVersion - int
		    @ID_PEDIDO,         -- IdPedido - int
		    GETDATE(), -- CreadoEl - datetime
		    @IdUsuario,         -- CreadoPor - int		    
		    1       -- Activo - bit
		  )



        SELECT 'NUEVO REGISTRO';
    END;
    ELSE
    BEGIN
        SELECT 'YA EXISTE UN REGISTRO';
    END;

END;

