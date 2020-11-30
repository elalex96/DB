-- =============================================
-- Author:		Pedro Acuña
-- Create date: 01/02/2018
-- Description:	obtener documento de la justificacion de la petOferta
-- Update:	11/05/2018 Cambio de retorno de infromación del usuario DANIEL AC
-- =============================================
CREATE PROCEDURE [dbo].[SP_AD_ObtenerDocumentoPorPetOferta]
    @IdSolicitudPedido INT,
    @IdContrato INT,
    @IdUsuario INT,
    @FechaRegistro DATETIME
AS
BEGIN
    
	SELECT  Carpeta,Identificador, Extension, Mime,NombreDocumento
	FROM dbo.MM_PeticionOfertaADAdjunto
	WHERE IdSolicitudPedido=@IdSolicitudPedido

END