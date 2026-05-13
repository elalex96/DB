
CREATE PROCEDURE [dbo].[SP_PV_ConsutarProveedoresEstadoPETROVENDOR]

@PaisNombre NVARCHAR(MAX)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 SELECT idEstado, Estado
    from Petrovendor.dbo.PV_EstadoRepublica AS ER
	LEFT JOIN dbo.PV_PaisRepublica AS PR ON PR.id = ER.idPais
	WHERE PR.pais = @PaisNombre
	
END


