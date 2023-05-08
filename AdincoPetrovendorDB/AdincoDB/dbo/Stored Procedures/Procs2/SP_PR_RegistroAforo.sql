CREATE PROCEDURE [dbo].[SP_PR_RegistroAforo]
@IdContrato INT,
@IdPozo INT,
@Fecha DATETIME,
@PresionCabeza FLOAT,
@Estrangulador FLOAT,
@PresionLinea FLOAT,
@Temperatura FLOAT,
@ProduccionPetroleo FLOAT,
@ProduccionGas FLOAT,
@ProduccionAgua FLOAT,
@RGA FLOAT,
@Observaciones VARCHAR(300),
--Nuevos valores
@PetroleoNeto FLOAT,
@CondensadoNeto FLOAT,
@GasNoAsociado FLOAT
AS
BEGIN
DECLARE @regionfiscal VARCHAR(250),
		@NombreCampo VARCHAR(250),
		@NombrePozo VARCHAR(250);


		
--SELECT 
--			@regionfiscal =p.RegionFiscal,
--			@NombreCampo=Campo.Nombre,
--			@NombrePozo= p.Nombre
--	FROM PR_Pozo p
--	inner join CO_Contrato c on c.IdContrato = 3
--	INNER JOIN PR_Campo AS Campo ON Campo.Id = p.Campo
--	inner join CO_PuntosdeEntregaContrato pec on pec.idContrato = c.IdContrato and
--									pec.PuntoEntregaID = p.PuntoEntregaID
--									WHERE p.Id = @IdPozo

INSERT INTO PR_Aforo	
(
IdContrato,
--RegionFiscal,
--NombreCampo,
IdPozo,
--NombrePozo,
Fecha,
PresionCabeza,
Estrangulador,
PresionLinea,
Temperatura,
ProduccionPetroleo,
ProduccionGas,
ProduccionAgua,
RGA,
Observaciones,
FechaCreacion,

PetroleoNeto,
CondensadoNeto,
GasNoAsociado
) VALUES(
@IdContrato,
--@regionfiscal,
--@NombreCampo,
@IdPozo,
--@NombrePozo,
@Fecha,@PresionCabeza,@Estrangulador,@PresionLinea,@Temperatura,@ProduccionPetroleo,@ProduccionGas,@ProduccionAgua,@RGA,@Observaciones,GETDATE(),@PetroleoNeto ,@CondensadoNeto,@GasNoAsociado)

END

