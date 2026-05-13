USE [Petrovendor]
GO
IF OBJECT_ID('SP_GiroEmpresarialFiltradoPorUso') IS NOT NULL
BEGIN
DROP PROCEDURE SP_GiroEmpresarialFiltradoPorUso;
END
GO
-- =============================================
-- Author:      Daniel Antonio Cruz
-- Create date: 23/04/2026
-- Description: Se agrega mejoras en consultas eiminado joins de más
-- =============================================
-- ============================================= 
-- Author:		Pedro Acuña
-- Create date: 05/Jun/2018
-- Description:	se filtran los giros comerciales por los que en realidad estan en uso pro los proveedores
-- =============================================
go 
CREATE PROCEDURE SP_GiroEmpresarialFiltradoPorUso
AS
	BEGIN
		CREATE TABLE #tablaAux 
			(
			  Id INT IDENTITY(1,1),
			  idGiroProveedor INT ,
			  GiroProveedor NVARCHAR(MAX) ,
			  Actividad NVARCHAR(MAX) ,
			  TipoActividad NVARCHAR(MAX))
		
		INSERT INTO #tablaAux
			( idGiroProveedor, GiroProveedor, Actividad, TipoActividad )
		VALUES
			( 0 ,							-- idGiroProveedor - int
			  N'Empresas que aún' ,				-- GiroProveedor - nvarchar(max)
			  N'no han registrado a que ' ,		-- Actividad - nvarchar(max)
			  N'giro empresarial pertenecen'	-- TipoActividad - nvarchar(max)
			)

		INSERT INTO #tablaAux
			( idGiroProveedor, GiroProveedor, Actividad, TipoActividad )
		SELECT		idGiroProveedor, GiroProveedor, GH.GiroProovedor AS Actividad, GP.GiroProovedor AS TipoActividad
		FROM		PV_GiroEmpresarial AS GE (NOLOCK)
		JOIN	PV_GiroComercialHijo AS GH  (NOLOCK)
			ON GE.PV_GiroComercialHijo = GH.IdGiroProveedorHijo
		JOIN	PV_GiroComercialPadre AS GP  (NOLOCK)
			ON GH.IdGiroProveedorPadre = GP.IdGiroProveedorPadre
		WHERE
	    GE.IdGiroProveedor IN
				(	SELECT	PGE.IdGiroEmpresarial
					FROM	PV_PerfilGiroEmpresarial AS PGE  (NOLOCK)				
					WHERE		PGE.Activo = 1 )
		ORDER BY GiroProveedor ASC

		SELECT
		idGiroProveedor ,
		GiroProveedor ,
	    Actividad,
	    TipoActividad 
		FROM #tablaAux
		ORDER BY Id ASC
	END
