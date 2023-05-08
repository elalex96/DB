-- =============================================
-- Author:	Daniel AC
-- Create date: 08/10/2019
-- Description:	Actualizar PO
-- =============================================
CREATE PROCEDURE [dbo].[DEA_SP_ActualizarNumeroPO] 
    -- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@IdUsuario INT,
    @IdRelacionPOPedido INT,
    @IdAdjuntoPO INT,
    @Comentario NVARCHAR(MAX),
    @NuevoNumeroPo NVARCHAR(MAX)
   
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	INSERT INTO dbo.DEA_AdjuntoHistorialPO
	(
	    IdAdjuntoPO,	   
	    CreadoPor,
	    CreadoEl,	    
	    Activo,	    
	    ID_PO_Anterior,
		ID_PO_Nuevo,
	    CargadaManualmente,
		Comentario
	)
	
	SELECT 
	IdAdjuntoPO,
	@IdUsuario,
	GETDATE(),
	1,
	ID_PO,
	@NuevoNumeroPo,
	CargadaManualmente,
	@Comentario
	FROM dbo.DEA_AdjuntoPO
	WHERE IdAdjuntoPO=@IdAdjuntoPO
	 
	 	
	UPDATE dbo.DEA_AdjuntoPO
	SET ID_PO=@NuevoNumeroPo,
	EditadoEl=GETDATE(),
	EditadoPor=@IdUsuario
	WHERE IdAdjuntoPO=@IdAdjuntoPO

	UPDATE dbo.DEA_Relacion_PR_PO
	SET PO=@NuevoNumeroPo
	WHERE ID_R_PR_PO=@IdRelacionPOPedido
	AND IdAdjuntoPO=@IdAdjuntoPO
	
	SELECT 'SUCCESS'  AS Response FROM dbo.DEA_AdjuntoPO WHERE IdAdjuntoPO=@IdAdjuntoPO
	  

END;



