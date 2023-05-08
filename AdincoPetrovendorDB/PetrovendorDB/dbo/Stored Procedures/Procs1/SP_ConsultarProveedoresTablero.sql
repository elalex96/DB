-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <08/07/2020>
-- Description:	<Consulta la lista de proveedores>
-- =============================================
CREATE PROCEDURE SP_ConsultarProveedoresTablero

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
	SELECT P.IdProveedor id, 
	LTRIM(P.IdProveedor) + ' - ' + P.RazonSocial [text] 
	FROM dbo.S_Proveedor P
	LEFT JOIN dbo.S_UsuarioProveedor UP
		ON UP.IdProveedor = P.IdProveedor
	WHERE ISNULL(P.IsEliminado,0) = 0 
	AND UP.IdContrato IS NOT NULL 
	GROUP BY
	P.IdProveedor,
	P.RazonSocial



END
