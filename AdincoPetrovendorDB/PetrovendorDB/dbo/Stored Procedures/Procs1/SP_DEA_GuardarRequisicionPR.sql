-- =============================================
-- Author:		Daniel AC
-- Create date: 27/04/2018
-- Description:	Agregar referencia a  documentos 
-- =============================================
CREATE  PROCEDURE[dbo].[SP_DEA_GuardarRequisicionPR] 
	-- Add the parameters for the stored procedure here
		 
	@IdProveedor INT,
	@IdUsuario INT,
	@NoRequisicionPR NVARCHAR(MAX),
	@NoSolicitudPedido INT,
	@Comentario NVARCHAR(MAX)

AS
	
BEGIN				
	
	DECLARE @ExisteRegistro INT 

	SELECT @ExisteRegistro=IdSolicitudPedido FROM dbo.DEA_AdjuntoPR WHERE IdSolicitudPedido=@NoSolicitudPedido AND @IdProveedor=@IdProveedor

	IF ISNULL(@ExisteRegistro,0)=0
	BEGIN 
     INSERT INTO dbo.DEA_AdjuntoPR
     (
         IdSolicitudPedido,        
         IdProveedor,
         Comentario,
         CreadoPor,
         CreadoEl,         
         Activo,       
         ID_PR
     )
     VALUES
     (   @NoSolicitudPedido,         -- IdSolicitudPedido - int         
         @IdProveedor,         -- IdProveedor - int
         @Comentario,       -- Comentario - nvarchar(max)
         @IdUsuario,         -- CreadoPor - int
         GETDATE(), -- CreadoEl - datetime        
         1,      -- Activo - bit         
         @NoRequisicionPR        -- ID_PR - nvarchar(30)
       )

	  SELECT @@IDENTITY AS IdAdjuntoPR

	END 
	ELSE 
	BEGIN 
		SELECT 'YA_EXISTE_PR'
	END 

END


