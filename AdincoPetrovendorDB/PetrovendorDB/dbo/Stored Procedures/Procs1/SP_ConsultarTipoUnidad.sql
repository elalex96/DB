CREATE procedure [dbo].[SP_ConsultarTipoUnidad]
	@Id INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	SELECT [Unidad] FROM [PV_MM_MaterialUnidad] (NOLOCK) WHERE IdUnidad = @Id
END