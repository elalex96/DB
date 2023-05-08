-- ============================================= 
-- Author:		Pedro Acuña
-- Create date: 05/Jun/2018
-- Description:	se filtran los giros comerciales por los que en realidad estan en uso pro los proveedores
-- =============================================

CREATE PROCEDURE SP_GiroEmpresarialFiltradoPorUso
AS
	BEGIN
		DECLARE @tablaAux TABLE
			( idGiroProveedor INT ,
			  GiroProveedor NVARCHAR(MAX) ,
			  Actividad NVARCHAR(MAX) ,
			  TipoActividad NVARCHAR(MAX))
		
		INSERT INTO @tablaAux
			( idGiroProveedor, GiroProveedor, Actividad, TipoActividad )
		VALUES
			( 0 ,							-- idGiroProveedor - int
			  N'Empresas que aún' ,				-- GiroProveedor - nvarchar(max)
			  N'no han registrado a que ' ,		-- Actividad - nvarchar(max)
			  N'giro empresarial pertenecen'	-- TipoActividad - nvarchar(max)
			)

		INSERT INTO @tablaAux
			( idGiroProveedor, GiroProveedor, Actividad, TipoActividad )
		SELECT		idGiroProveedor, GiroProveedor, GH.GiroProovedor AS Actividad, GP.GiroProovedor AS TipoActividad
		FROM		PV_GiroEmpresarial AS GE
		INNER JOIN	PV_GiroComercialHijo AS GH
			ON GH.IdGiroProveedorHijo = GE.PV_GiroComercialHijo
		INNER JOIN	PV_GiroComercialPadre AS GP
			ON GP.IdGiroProveedorPadre = GH.IdGiroProveedorPadre
		WHERE
					GE.IdGiroProveedor IN
						(	SELECT		PGE.IdGiroEmpresarial
							FROM		dbo.S_Proveedor p
							LEFT JOIN	dbo.PV_PerfilGiroEmpresarial AS PGE
								ON PGE.IdProveedor = p.IdProveedor
							LEFT JOIN	dbo.PV_GiroEmpresarial AS GE
								ON GE.IdGiroProveedor = PGE.IdGiroEmpresarial
							WHERE		PGE.Activo = 1 )

		

			SELECT * FROM @tablaAux
	END
