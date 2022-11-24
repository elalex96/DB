-- =============================================
-- Author:		Reyna Olvera
-- Create date: 07-10-2019
-- Description:	Modifica anuncios 
-- =============================================
CREATE PROCEDURE sp_CO_ModificaAnuncios 
@IdAnuncio INT,
@IdContrato INT,
@Anuncio varchar(MAX),
@URL varchar(MAX),
@FechaInicio DATETIME,
@FechaVigencia DATETIME,
@DiasNovedad INT,
@IdUsuario INT
AS
BEGIN

UPDATE CO_Anuncio
SET 
IdContrato=@IdContrato,
Anuncio=@Anuncio,
URL=@URL,
FechaInicio=@FechaInicio,
FechaVigencia=@FechaVigencia,
DiasNovedad=@DiasNovedad,
ModificadoPor=@IdUsuario,
ModificadoEl= GETDATE()
WHERE IdAnuncio=@IdAnuncio;

END;
