DROP PROCEDURE IF EXISTS EN_sp_GuardaBitacoraExcepcion
-- =============================================
-- Author:		LUIS DAVID
-- Create date: 27/02/2021
-- Description:	<INSERTA EN LA BITACORA DE EXCEPCIONES>
-- =============================================
go
CREATE PROCEDURE EN_sp_GuardaBitacoraExcepcion
@IdInstanciaEntregable int,
@FechaCalculadaEntregaRegAnterior date,
@UsuarioId int,
@ContratoId int
AS
BEGIN
	INSERT INTO EN_ExcepcionesFechaBitacora(
	IdInstanciaEntregable,		FechaCalculadaEntregaRegAnterior,	UsuarioId,	ContratoId, FechaMovimiento) values (
	@IdInstanciaEntregable,		@FechaCalculadaEntregaRegAnterior,	@UsuarioId,	@ContratoId, GETDATE())
END