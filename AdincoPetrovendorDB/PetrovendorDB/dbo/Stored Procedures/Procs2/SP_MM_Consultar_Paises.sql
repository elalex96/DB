-- =============================================
-- Author:		DANIEL AC
-- Create date: 20-09-17
-- Description:	Consultar FILTRO DE PROVEEDORES
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_Consultar_Paises]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	CREATE TABLE #PAIS(IdPais int, Nombre NVARCHAR(350))
	INSERT INTO #PAIS(IdPais, Nombre)
	VALUES (0,'Todos')

	INSERT INTO #PAIS(IdPais, Nombre)
	SELECT PA.id, PA.pais
	FROM S_Proveedor  AS P
	INNER JOIN dbo.S_UsuarioProveedor AS PU ON PU.IdProveedor= P.IdProveedor
	LEFT JOIN PV_PaisRepublica AS PA ON PA.Id = P.IdPais 
	LEFT JOIN DG_Domicilio AS D ON D.Idpais = PA.Id    
	WHERE P.Activo= 1 AND P.IdPais IS NOT NULL AND P.IdPais <> 42	
	GROUP BY PA.id,PA.pais
	ORDER BY PA.pais ASC
	 
	SELECT * FROM #PAIS WHERE IdPais IS NOT NULL
END
