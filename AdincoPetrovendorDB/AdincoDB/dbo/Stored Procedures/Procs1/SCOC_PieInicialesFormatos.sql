-- =============================================
-- Author:	Reyna Olvera
-- Create date: 20190121
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SCOC_PieInicialesFormatos
	@IdContrato INT,
	@IdUsuario INT
AS
BEGIN

	SET NOCOUNT ON;
SELECT 'INICIALES' AS FindInicial,
       ISNULL(InicialesSocio, '') AS Iniciales,
       '<PUNTOENTREGA>' AS FindPE,
       ISNULL(DescripcionSocio, '') AS DescripcionSocio,
       '<DESCRIPCIONCONTRATISTA>' AS FindDC,
       ISNULL(PuntosLecturaCroma, '') AS PuntosEntrega
  FROM dbo.SCOC_Contrato
 WHERE IdContrato = @IdContrato;
END
