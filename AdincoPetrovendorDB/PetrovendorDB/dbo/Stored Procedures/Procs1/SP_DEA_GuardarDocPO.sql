USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_DEA_GuardarDocPO]    Script Date: 31/03/2022 11:02:29 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <22/08/2019>
-- Description:	<Guardar la PO del Correo>
-- =============================================
ALTER PROCEDURE [dbo].[SP_DEA_GuardarDocPO]
	-- Add the parameters for the stored procedure here
	@ID_PO NVARCHAR(MAX),
	@Mime NVARCHAR(MAX),
	@Carpeta NVARCHAR(MAX),
	@Extension NVARCHAR(MAX),
	@Identificador NVARCHAR(MAX),
	@NombreDocumento NVARCHAR(MAX),
	@Descripcion NVARCHAR(MAX),
	@SizeDocumento NVARCHAR(MAX),
	@CargadoPorUsuarioID INT,
	@CargadaManualmente BIT,
	@Bucket NVARCHAR(MAX) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IDDOCPO INT;
	DECLARE @IDDOCUMENTO INT;
	DECLARE @ExistePO INT, @ExisteImportado INT;
	DECLARE @ExisteRelacionPO INT , @ExisteRelacionPedidoPR INT, @IdProveedor INT;

	IF @CargadaManualmente =  0 
		SET @CargadoPorUsuarioID = NULL 
    -- Insert statements for procedure here
	INSERT INTO dbo.DEA_AdjuntoPO
	(
	    CreadoEl,
	    Activo,
	    ID_PO,
		CreadoPor,
		CargadaManualmente
	)
	VALUES
	( 
	    GETDATE(), -- CreadoEl - datetime
	    1,      -- Activo - bit
	    @ID_PO ,       -- ID_PO - nvarchar(max)
		@CargadoPorUsuarioID,
		@CargadaManualmente
	 )

	SET @IDDOCPO = SCOPE_IDENTITY();

	INSERT INTO dbo.DEA_Documento_S3   
   (
       IdTipoDocumento,         
       IdProveedor,
       Activo,       
       CreadoPor,
       CreadoEl,     
       Descripcion,
       Carpeta,
       Identificador,
       Mime,
       Extension,
       NombreDocumento,
       SizeDocumento,
	   IdDocumentoTabla,
	   Bucket
   )
   VALUES
   (   2,         -- IdTipoDocumento - int      
       NULL,         -- IdProveedor - int
       1,      -- Activo - bit    
       @CargadoPorUsuarioID,         -- CreadoPor - int
       GETDATE(), -- CreadoEl - datetime      
       @Descripcion,       -- Descripcion - nvarchar(max)
       @Carpeta,       -- Carpeta - nvarchar(max)
       @Identificador,       -- Identificador - nvarchar(max)
       @Mime,       -- Mime - nvarchar(max)
       @Extension,       -- Extension - nvarchar(max)
       @NombreDocumento,       -- NombreDocumento - nvarchar(max)
       @SizeDocumento,
	   @IDDOCPO,
	   @Bucket
      )

	  SET @IDDOCUMENTO = SCOPE_IDENTITY();

	  UPDATE dbo.DEA_AdjuntoPO
	  SET IdDocumento = @IDDOCUMENTO
	  WHERE IdAdjuntoPO = @IDDOCPO;

	  --SE BUSCA EN IMPORTACION
	  SET @ExisteImportado = (SELECT TOP 1 IdPedidoADINCO FROM WDEA_PurchasingDocumentsImportados WHERE PURCHASING_DOCUMENT = @ID_PO);
	  SET @IdProveedor = (SELECT TOP 1 IdProveedorCompras FROM MM_Pedido WHERE IdPedido = @ExisteImportado);

	  IF ISNULL(@ExisteImportado,0) > 0
	  BEGIN
			--VALIDAR SI LA PO NO ESTA RELACIONADA
			SELECT @ExisteRelacionPO =COUNT(ID_R_PR_PO)
			FROM DEA_Relacion_PR_PO  RP
			INNER JOIN dbo.MM_Pedido P ON P.IdPedido=RP.IdPedido	
			WHERE RP.IdAdjuntoPO=@IDDOCPO 
			AND ISNULL(P.IdEstatusEliminado,0)=0  --> SI EL PEDIDO ESTA ELIMINADO SI SE PUEDE VOLVER A RELACIONAR LA PO 
 
			--VALIDAR QUE EL PEDIDO-PR NO ESTE RELACIONADO 
			SELECT @ExisteRelacionPedidoPR =COUNT(ID_R_PR_PO)
			FROM DEA_Relacion_PR_PO  RP
			INNER JOIN dbo.MM_Pedido P ON P.IdPedido=RP.IdPedido
			WHERE RP.IdPedido=@ExisteImportado 
			AND ISNULL(P.IdEstatusEliminado,0)=0  --> SI EL PEDIDO ESTA ELIMINADO SI SE PUEDE VOLVER A RELACIONAR LA PO 
  
			--SI LA PO Y EL PEDIDO PR NO ESTAN RELACIONADOS AGREGAR NUEVA RELACIÓN
			IF ISNULL(@ExisteRelacionPO,0)=0  AND ISNULL(@ExisteRelacionPedidoPR,0)=0
			BEGIN 

				-- Insert statements for procedure here
				INSERT INTO dbo.DEA_Relacion_PR_PO
				(
					PO,
					IdPedido,
					FechaAltaRelacion,
					Activo,
					IdCreadoProveedor,
					IdAdjuntoPO
				)
				VALUES
				(   @ID_PO,       -- PR - nvarchar(30)
					@ExisteImportado,       -- PO - nvarchar(30)
					GETDATE(), -- FechaAltaRelacion - datetime
					1,      -- Activo - bit
					@IdProveedor,
					@IDDOCPO
				)

				SET @ExisteRelacionPO = (SELECT SCOPE_IDENTITY());

			END
	  END


	  SELECT
		IdAdjuntoPO,
		IdDocumento,
		ISNULL(@ExisteRelacionPO,0) AS Relacion,
		ISNULL(@ExisteImportado,0) AS Pedido,
		ID_PO
	  FROM dbo.DEA_AdjuntoPO
	  WHERE IdAdjuntoPO = @IDDOCPO
		
END
