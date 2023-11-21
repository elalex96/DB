
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FI_ViewPdfEstudio'
)
    DROP PROCEDURE SP_FI_ViewPdfEstudio
GO
-- =============================================
-- Author:		Manuel CD
-- Create date: 12-10-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ViewPdfEstudio] 
@IdEstudio INT
AS
     BEGIN
         SET NOCOUNT ON;


         SELECT E.IdEstudioPrecioTransfer,
                E.Archivo
         FROM FI_EstudioPreciosTransfer E (NOLOCK)
         WHERE E.IdEstudioPrecioTransfer = @IdEstudio;
     END;
