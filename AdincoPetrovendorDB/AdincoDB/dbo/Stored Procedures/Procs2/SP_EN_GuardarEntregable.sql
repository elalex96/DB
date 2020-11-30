-- =============================================
-- Author:		Manuel CD
-- Create date: 22-11-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_GuardarEntregable] 
	-- Add the parameters for the stored procedure here
@IdContrato           INT,
@FechaDocumento       DATE,
@NoReferencia         NVARCHAR(100),
@NombreDocumento      NVARCHAR(MAX),
@ClvTipo              INT,
@NombreArchivo        NVARCHAR(MAX),
@Extension            NVARCHAR(MAX),
@Archivo              IMAGE,
@IdEntregable         INT,
@IdActividadPetrolera INT,
@IdUsuario            INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;
    -- Insert statements for procedure here
             INSERT INTO [dbo].[EN_Documento]
		  ([IdContrato],
		   [FechaDocumento],
		   [NoReferencia],
		   [NombreDocumento],
		   [ClvTipo],
		   [NombreArchivo],
		   [Extension],
		   [Archivo],
		   [IdEntregable],
		   [IdActividadPetrolera],
		   [IsActivo],
		   [IsEliminado],
		   [CreadoPor],
		   [CreadoEl]
		  )
             VALUES
		  (@IdContrato,
		   @FechaDocumento,
		   @NoReferencia,
		   @NombreDocumento,
		   @ClvTipo,
		   @NombreArchivo,
		   @Extension,
		   @Archivo,
		   @IdEntregable,
		   @IdActividadPetrolera,
		   1,
		   0,
		   @IdUsuario,
		   GETDATE()
		  )

	    IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;

         END