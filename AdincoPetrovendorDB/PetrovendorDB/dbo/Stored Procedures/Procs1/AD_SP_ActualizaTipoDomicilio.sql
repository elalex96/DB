-- =============================================
-- Author:		Daniel Cruz
-- Create date: 22/01/2018
-- Description:	ACTUALIZAR NUEVO TIPO DE DOMICILIO 
-- =============================================
CREATE PROCEDURE [dbo].[AD_SP_ActualizaTipoDomicilio] 
	-- Add the parameters for the stored procedure here
@IdProveedor INT,
@IdUsuario INT, 
@IdContrato INT, 
@FechaRegistro DATETIME,
@TipoDomicilio NVARCHAR(300),
@IdTipoDomicilio INT,
@Activo BIT 

AS
   BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
		
    -- Insert statements for procedure here
         
		UPDATE dbo.DG_TipoDomicilio
		SET TipoDomicilio=@TipoDomicilio,
        Activo=@Activo,
		EditadorPor=@IdUsuario,
        EditadoEl=GETDATE()
		WHERE IdTipoDomicilio=@IdTipoDomicilio
			 		     
 END; 
