
-- =============================================
CREATE PROCEDURE [SP_DEA_ValidarClienteDEA] 
	-- Add the parameters for the stored procedure here
	@IdProveedor int, 
	@IdUsuario INT,
	@IdPedido INT 
AS
BEGIN
	
	DECLARE @IdProveedorCliente  INT 
	DECLARE @EsProveedorDEA INT 

	SELECT @IdProveedorCliente= IdProveedorCompras
	FROM dbo.MM_Pedido 
	WHERE IdPedido=@IdPedido


	SELECT @EsProveedorDEA =IdProveedor
	FROM dbo.DEA_Proveedor 
	WHERE IdProveedor=@IdProveedorCliente
	AND Activo=1 

	IF ISNULL(@EsProveedorDEA,0) > 0  
	BEGIN 
		
		SELECT 'ES_CLIENTEDEA', ISNULL(D.IdDocumento,0) AS IdDocumento, ISNULL(PO.ID_PO,'NO INDENTIFICADO') AS NoPO, ISNULL(P.IdPedido,0), ISNULL(P.IdProveedorCompras,0) AS Cliente,P.IdPedido, D.Activo
		FROM dbo.MM_Pedido P
		INNER JOIN dbo.DEA_Relacion_PR_PO RPO ON P.IdPedido=RPO.IdPedido
		INNER JOIN dbo.DEA_AdjuntoPO PO ON RPO.IdAdjuntoPO=PO.IdAdjuntoPO	
		LEFT JOIN dbo.DEA_Documento_S3 D ON D.IdDocumento=PO.IdDocumento AND D.IdTipoDocumento=2 ---> PO 
		WHERE P.IdPedido=@IdPedido
	
	END 


END

