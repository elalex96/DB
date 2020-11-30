-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <29/01/2020>
-- Description:	<Consulta de los proveedores>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaProveedoresPeticionOferta] --0,'',1
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@Buscar NVARCHAR(200),
	@Page INT,
	/*--------------------
	parametros contrato
	--------------------*/
	@IdContrato    INT = NULL,
	@IdUsuario     INT = NULL,
	@FechaRegistro DATETIME = NULL
	  /*--------------------
	  --------------------*/
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @RecordsByPage INT = 16;
	DECLARE @AllRecords INT = (
						SELECT COUNT(1) 
						FROM dbo.S_Proveedor AS P
						--INNER JOIN dbo.S_UsuarioProveedor AS UP
						--	ON UP.IdProveedor = P.IdProveedor
						--		AND UP.IsAdmin = 1
						--INNER JOIN dbo.S_Usuario AS U
						--	ON U.IdUsuario = UP.IdUsuario
						--		AND U.IdTipoUsuario = 3
						--		AND U.Activo = 1
						LEFT JOIN dbo.S_ImagenPerfil AS IMP
							ON IMP.IdProveedor = P.IdProveedor
						LEFT JOIN Adinco.dbo.ListaNegra AS LN
							ON LN.RFC COLLATE Modern_Spanish_CI_AS = P.RFC COLLATE Modern_Spanish_CI_AS
						WHERE P.Activo = 1
							AND P.IdProveedor <> @IdProveedor
							AND ISNULL(P.IsEliminado,0) = 0
							AND P.RFC COLLATE Modern_Spanish_CI_AS NOT IN (SELECT RFC FROM Adinco..CO_Contratista WHERE RFC IS NOT NULL)
							AND P.RazonSocial LIKE '%' + @Buscar + '%'
						);


	SELECT 
		*,
		@AllRecords AS Records,
		@RecordsByPage AS RecordByPage
	FROM 
	(
		SELECT 
			ROW_NUMBER() OVER(PARTITION BY P.IdProveedor ORDER BY P.RazonSocial ASC) AS R,
			P.IdProveedor,
			P.RazonSocial + ' ' + ISNULL(P.RegimenCapital,'') AS RazonSocial,
			isnull((SELECT TOP 1
				US.Correo
			FROM dbo.S_UsuarioProveedor AS UPR
				LEFT JOIN dbo.S_Usuario AS US ON US.IdUsuario = UPR.IdUsuario
			WHERE UPR.IdProveedor = P.IdProveedor
				AND US.IdTipoUsuario = 3
				AND US.Activo = 1
			ORDER BY US.FechaRegistro DESC
			),'') AS CorreoEmpresa,
			--Correo AS CorreoEmpresa,
			dbo.ObtenerEstrellasModificado(P.IdProveedor) AS Estrellas,
			CASE
				WHEN LN.RFC IS NULL THEN 0
				ELSE 1
			END AS IsBlackList,
			IMP.ImagenProveedorThumb AS ImagenProveedor,
			dbo.FN_PedidosSubContratista(P.IdProveedor) AS PedidosRealizados,
			dbo.FN_AntiguedadSubContratista(P.IdProveedor) AS AntiguedadSubContratista,
			dbo.FN_CantidadClientesSubContratista(P.IdProveedor) AS CantidadClientes,
			(ROW_NUMBER() OVER(ORDER BY P.RazonSocial DESC) - 1)/ @RecordsByPage _Page
		FROM dbo.S_Proveedor AS P
			--INNER JOIN dbo.S_UsuarioProveedor AS UP
			--	ON UP.IdProveedor = P.IdProveedor
			--		AND UP.IsAdmin = 1
			--INNER JOIN dbo.S_Usuario AS U
			--	ON U.IdUsuario = UP.IdUsuario
			--		AND U.IdTipoUsuario = 3
			--		AND U.Activo = 1
			LEFT JOIN dbo.S_ImagenPerfil AS IMP
				ON IMP.IdProveedor = P.IdProveedor
			LEFT JOIN Adinco.dbo.ListaNegra AS LN
				ON LN.RFC COLLATE Modern_Spanish_CI_AS = P.RFC COLLATE Modern_Spanish_CI_AS
			WHERE P.Activo = 1
				AND P.IdProveedor <> @IdProveedor
				AND ISNULL(P.IsEliminado,0) = 0
				AND P.RFC COLLATE Modern_Spanish_CI_AS NOT IN (SELECT RFC FROM Adinco..CO_Contratista WHERE RFC IS NOT NULL)
				AND P.RazonSocial LIKE '%' + @Buscar + '%'
	)
	AS R WHERE R.R = 1
	AND R._Page = (@Page - 1)
	ORDER BY R.RazonSocial

END
