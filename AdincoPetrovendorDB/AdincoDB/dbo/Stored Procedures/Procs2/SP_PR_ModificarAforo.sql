--DROP PROCEDURE SP_PR_ModificarAforo
CREATE PROCEDURE [dbo].[SP_PR_ModificarAforo]
@IdAforo INT,
@PresionCabeza FLOAT,
@Estrangulador FLOAT,
@PresionLinea FLOAT,
@Temperatura FLOAT,
@ProduccionPetroleo FLOAT,
@ProduccionGas FLOAT,
@ProduccionAgua FLOAT,
@RGA FLOAT,
@Observaciones varchar(150),
@PetroleoNeto FLOAT,
@CondensadoNeto FLOAT,
@GasNoAsociado FLOAT

AS
BEGIN
UPDATE dbo.PR_Aforo
SET PresionCabeza =@PresionCabeza
,Estrangulador=@Estrangulador
,PresionLinea=@PresionLinea
,Temperatura=@Temperatura
,ProduccionPetroleo=ProduccionPetroleo
,ProduccionGas=@ProduccionGas
,ProduccionAgua=ProduccionAgua
,RGA=@RGA
,Observaciones=@Observaciones
,FechaModificacion =GETDATE()
,PetroleoNeto = @PetroleoNeto
,CondensadoNeto = @CondensadoNeto
,GasNoAsociado = @GasNoAsociado
WHERE IdAforo =@IdAforo
END
