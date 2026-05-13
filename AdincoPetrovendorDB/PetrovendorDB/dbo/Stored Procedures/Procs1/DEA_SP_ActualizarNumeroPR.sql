-- =============================================
-- Author:	Daniel AC
-- Create date: 16/10/2019
-- Description:	Actualizar PR
-- =============================================
CREATE PROCEDURE [dbo].[DEA_SP_ActualizarNumeroPR] 
    -- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@IdUsuario INT,
    @IdSolicitudPedido INT,   
    @Comentario NVARCHAR(MAX),
    @NuevoNumeroPr NVARCHAR(MAX)
   
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	INSERT INTO dbo.DEA_AdjuntoHistorialPR	
	(
	    IdSolicitudPedido,	
		IdAjuntoPr,    
	    IdProveedor,
	    Comentario_Anterior,
	    CreadoPor,
	    CreadoEl,
		ID_PR_Anterior,
		ID_PR_Nuevo,
		Activo)	

	SELECT 
	IdSolicitudPedido,
	IdAjuntoPr,
	IdProveedor, 
	Comentario, 
	@IdUsuario,
	GETDATE(),
	ID_PR,
	@NuevoNumeroPr,
	Activo
	FROM dbo.DEA_AdjuntoPR 
	WHERE IdSolicitudPedido=@IdSolicitudPedido
	 
	 	
	UPDATE dbo.DEA_AdjuntoPR
	SET ID_PR=@NuevoNumeroPr,
	Comentario=@Comentario,
	EditadoEl=GETDATE(),
	EditadoPor=@IdUsuario
	WHERE IdSolicitudPedido=@IdSolicitudPedido
	
	SELECT 'SUCCESS'  AS Response 
	FROM dbo.DEA_AdjuntoPR 
	WHERE IdSolicitudPedido=@IdSolicitudPedido
	  

END;




