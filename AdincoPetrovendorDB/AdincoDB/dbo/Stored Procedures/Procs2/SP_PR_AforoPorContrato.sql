CREATE PROCEDURE [dbo].[SP_PR_AforoPorContrato]
@IdContrato int 
AS
BEGIN
		SELECT 
		AF.IdAforo
		,Po.Nombre
		,AF.IdContrato 
		,AF.Fecha
		,AF.PresionCabeza
		,AF.PresionLinea
		,AF.Estrangulador
		,AF.Temperatura
		,AF.ProduccionPetroleo
		,AF.ProduccionGas
		,AF.ProduccionAgua
		,AF.RGA
		,AF.Observaciones,
		AF.PetroleoNeto,AF.CondensadoNeto,
		AF.GasNoAsociado
		FROM dbo.PR_Aforo AS AF
		INNER JOIN dbo.PR_Pozo AS PO ON AF.IdPozo = PO.Id
		WHERE AF.idcontrato =@IdContrato
END

