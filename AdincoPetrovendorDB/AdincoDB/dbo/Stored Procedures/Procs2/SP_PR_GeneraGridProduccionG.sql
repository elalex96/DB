-- =============================================
-- Author:		Reyna Olvera
-- Create date: 21/03/2018
-- Description:	Para que el usuario observe que esta agregado
-- =============================================
CREATE PROCEDURE [dbo].[SP_PR_GeneraGridProduccionG]
	-- Add the parameters for the stored procedure here
@Idcontrato int ,
@fechaMesDiaAnio date,
@puntoEntrega int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

Select PE.Nombre as NombrePuntoEntrega, 
CP.Nombre as Hidrocarburo,
CASE WHEN VolumenProgramado IS NULL 
			THEN 0
			ELSE VolumenProgramado
			END 
			AS Volumen,
			UM.Abreviatura as Unidad
from PR_ProduccionMensualSipac PS
JOIN CO_PuntosdeEntrega PE on PS.PuntoEntregaID= PE.puntoEntregaID
JOIN CO_ClasificacionProductoNominacion CP on PS.idHidrocarburo= CP.ProductoNominacionID
JOIN CO_UnidadMedida UM on PS.idUnidadMedida = UM.idUnidadMedida
where idFecha=@fechaMesDiaAnio
 and idContrato=@Idcontrato 
 and PS.PuntoEntregaID=@puntoEntrega
--and PS.idHidrocarburo!= 1001

END
