
-- =============================================
-- Author:		Pedro acuna
-- Create date: 06-02-2020
-- Description:	obtener el rfc de pcm
-- =============================================
CREATE PROCEDURE ObtenerRfcPCM
AS
BEGIN
   SELECT RFC FROM dbo.PCM_RFC
END;

