-- =============================================
-- Author:		DANIEL AC
-- Create date: 09-04-18
-- Description:	Agregar o Actualizar pedimento
-- =============================================
-- =============================================
-- Author:		PEDRO ACU�A
-- Create date: 25-06-18
-- Description:	se agrega como filtro la nacionalidad
-- =============================================

CREATE PROCEDURE SP_PC_CD_ConsultarProveedor @IdProveedor INT, @IdContrato INT, @IdUsuario INT
AS
	BEGIN
		SET NOCOUNT ON

		SELECT		IdProveedor, RFC, CONCAT ( RazonSocial, ' ', ISNULL ( S.RegimenCapital, '' )) AS Proveedor
		FROM		dbo.S_Proveedor S
		WHERE		S.IdNacionalidad = 2	-- Extranjera
		ORDER BY	S.RazonSocial ASC
	END