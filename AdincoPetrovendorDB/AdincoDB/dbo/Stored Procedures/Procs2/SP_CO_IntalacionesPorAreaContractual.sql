-- =============================================
-- Author:		Manuel CD
-- Create date: 18-09-17
-- Description:	
-- =============================================
create PROCEDURE [dbo].[SP_CO_IntalacionesPorAreaContractual] 
	-- Add the parameters for the stored procedure here
@IdContrato INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         SELECT I.IdInstalacion,
                I.NombreInstalacion,
                I.IdInstalacionPemex,
                I.EsBolsa,
                A.NombreActividad,
                I.FecMovto,
                I.NombreInstalacionAlterno,
                I.IdCatalogoSCIEP,
                I.Activo,
                I.CUIP,
                I.WelIID,
                CP.NombreCampo,
                I.UTMX,
                I.UTMY,
                UC.Nombre AS CreadoPor,
			 UM.Nombre AS ModificadoPor
         FROM CO_Instalacion AS I
              LEFT JOIN CO_Contrato AS C ON I.IdAreaContractual = C.IdAreaContractual
		    LEFT JOIN CO_ActividadCIEP AS A ON A.IdActividad = I.IdActividad
		    LEFT JOIN AP_Usuario AS UC ON I.CreadoPor = UC.UsuarioID
		    LEFT JOIN AP_Usuario AS UM ON I.ModificadoPor = UM.UsuarioID
		    LEFT JOIN PD_Campo AS CP ON CP.IdCampo = I.IdCampo
		    LEFT JOIN CO_Yacimiento AS Y ON Y.IdYacimiento = I.IdYacimiento
         WHERE(C.IdContrato = @IdContrato);
     END;
