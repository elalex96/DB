-- =============================================
-- Author:		Reyna Olvera
-- Create date: 07-10-2019
-- Description:	Inserta anuncios 
-- =============================================
CREATE PROCEDURE sp_CO_InsertaAnuncios
@IdContrato INT,
@Anuncio varchar(MAX),
@URL varchar(MAX),
@FechaInicio DATETIME,
@FechaVigencia DATETIME,
@DiasNovedad INT,
@IdUsuario INT
AS
BEGIN
  INSERT INTO dbo.CO_Anuncio
  (
      IdContrato,
      Anuncio,
      URL,
      FechaInicio,
      FechaVigencia,
	  DiasNovedad,
      CreadoPor,
      CreadoEl
  )
  VALUES
  (   @IdContrato,         -- IdContrato - int
      @Anuncio,        -- Anuncio - varchar(max)
      @URL,        -- URL - varchar(max)
       @FechaInicio, -- FechaInicio - date
      @FechaVigencia, -- FechaVigencia - date
	  @DiasNovedad,
      @IdUsuario,         -- CreadoPor - int
      GETDATE()         -- CreadoEl - int
      );


END;