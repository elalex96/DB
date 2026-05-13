create procedure [dbo].[SP_PV_ConsultaTipoPersonaFiscal]
as
begin

select TP.TipoPersonaFiscalID, TP.TipoPersonaFiscal
from [dbo].[PV_TipoPersonaFiscal] 
as TP

end