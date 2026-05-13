USE Adinco
GO
DROP PROCEDURE IF EXISTS SP_AP_GuardaBitacoraAccion
GO
CREATE PROCEDURE [dbo].[SP_AP_GuardaBitacoraAccion]
    @Mensaje VARCHAR(1500),
	@Detalle VARCHAR(1500),
    @ContratoId INT = 0,
    @UsuarioId INT = 0,
	@Tipo varchar(500)
AS
BEGIN
declare @Usuario varchar(500) = (SELECT Nombre FROM AP_USUARIO WHERE UsuarioID = @UsuarioId),
@Contrato varchar(500) = (
select top 1 CONCAT(NumeroContrato,' - ',NombreAreaContractual) from co_contrato as c 
join CO_AreaContractual ac 
on c.IdAreaContractual = ac.IdAreaContractual
where IdContrato = @ContratoId);



SET @Detalle = ( SELECT REPLACE(@Detalle, '##Usuario###', @Usuario));
SET @Detalle = ( SELECT REPLACE(@Detalle, '##Fecha##', CONVERT(varchar,GETDATE(),13)));
SET @Detalle = ( SELECT REPLACE(@Detalle, '##Contrato##', @Contrato));

INSERT INTO AP_Bitacora
	(
		[Fecha],
        [Tipo],
        [Mensaje],
        [Detalle],
        [UsuarioId],
        [ContratoId])
     VALUES
     (
		GETDATE(),
        @Tipo,
        @Mensaje,
        @Detalle,
        @UsuarioId,
        @ContratoId)
END