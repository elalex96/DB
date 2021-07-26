USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_DEA_GuardarDocPO'
)
    DROP PROCEDURE SP_DEA_GuardarDocPO;
/****** Object:  StoredProcedure [dbo].[SP_DEA_GuardarDocPO]    Script Date: 20/07/2021 02:54:49 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <22/08/2019>
-- Description:	<Guardar la PO del Correo>
-- =============================================
CREATE PROCEDURE [dbo].[SP_DEA_GuardarDocPO]
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
	@Bucket NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IDDOCPO INT;
	DECLARE @IDDOCUMENTO INT;
	DECLARE @ExistePO INT 

	--SELECT @ExistePO = COUNT(IdAdjuntoPO) FROM dbo.DEA_AdjuntoPO WHERE ID_PO=@ID_PO

	--IF ISNULL(@ExistePO,0)=0

	--BEGIN 

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

	  SELECT
		IdAdjuntoPO,
		IdDocumento
	  FROM dbo.DEA_AdjuntoPO
	  WHERE IdAdjuntoPO = @IDDOCPO

	  --END 
	 -- ELSE 
	 -- BEGIN 
		--SELECT -1,'PO_YA_EXISTENTE'
	 -- END 
		
END



