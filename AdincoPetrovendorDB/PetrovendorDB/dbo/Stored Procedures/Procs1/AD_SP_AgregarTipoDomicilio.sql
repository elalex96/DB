-- =============================================
-- Author:		Daniel Cruz
-- Create date: 22/01/2018
-- Description:	AGREGAR NUEVO TIPO DE DOMICILIO 
-- =============================================
CREATE PROCEDURE [dbo].[AD_SP_AgregarTipoDomicilio] 
	-- Add the parameters for the stored procedure here
@IdProveedor INT,
@IdUsuario INT, 
@IdContrato INT, 
@FechaRegistro DATETIME,
@TipoDomicilio NVARCHAR(300),
@Activo bit  

AS
   BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
		
    -- Insert statements for procedure here
         
		 INSERT INTO dbo.DG_TipoDomicilio
		 (
		     TipoDomicilio,
		     Activo,
		     CreadoPor,		     
		     CreadoEl
		     
		 )
		 VALUES
		 (   @TipoDomicilio,       -- TipoDomicilio - nvarchar(300)
		     1,      -- Activo - bit
		     @IdUsuario,         -- CreadoPor - int		    
		     GETDATE() -- CreadoEl - datetime		    
		     )
			 		     
 END; 
