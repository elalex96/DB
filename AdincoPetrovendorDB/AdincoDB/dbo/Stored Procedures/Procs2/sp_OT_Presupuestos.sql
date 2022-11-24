
CREATE Proc [dbo].[sp_OT_Presupuestos]  
@pIdContratista int,  
@pIdSubContrato int,  
@pSoloSeleccionados bit=0  
As  
  
  
 select p.IdPresupuesto,
       NombrePresupuesto = p.Nombre,
       p.Comentario,
       p.FechaAprobacionPEP,
       P.IdPresupuestoCNH
into #tmpResult
from CO_Presupuesto p (NOLOCK)
    inner join [dbo].[CO_ProgramaActividad] pa (NOLOCK)
        on p.[IdProgramaActividad] = pa.[IdProgramaActividad] 
    inner join [dbo].[CO_PeriodoContrato] pc (NOLOCK)
        on pa.IdPeriodoContrato = pc.IdPeriodo 
    inner join CO_Contrato con (NOLOCK)
        on pc.IdContrato = con.IdContrato 
            and con.IdContratista = @pIdContratista
    inner join SC_Presupuesto scp (NOLOCK)
        on p.IdPresupuesto = scp.IdPresupuesto
           and scp.IdSubContrato = @pIdSubContrato
where p.Actual = 1
      and (
              (
                  @pSoloSeleccionados = 1
                  and scp.IdSubContratoPresupuesto is not null
              )
              OR (@pSoloSeleccionados = 0)
          )
group by p.IdPresupuesto,
         p.Nombre,
         p.Comentario,
         p.FechaAprobacionPEP,
         P.IdPresupuestoCNH
Order by p.IdPresupuesto desc,
         p.Nombre

if not exists (select 1 from #tmpResult)
begin

    insert into #tmpResult
    select p.IdPresupuesto,
           NombrePresupuesto = p.Nombre,
           p.Comentario,
           p.FechaAprobacionPEP,
           P.IdPresupuestoCNH
    from CO_Presupuesto p (NOLOCK)
        inner join SC_SubContrato sc (NOLOCK)
            on sc.IdSubContrato = @pIdSubContrato
				and @pIdSubContrato > 0
        inner join [dbo].[CO_ProgramaActividad] pa (NOLOCK)
            on p.[IdProgramaActividad] = pa.[IdProgramaActividad] 
        inner join [dbo].[CO_PeriodoContrato] pc (NOLOCK)
            on pa.IdPeriodoContrato = pc.IdPeriodo  
        inner join CO_Contrato con (NOLOCK)
            on con.IdContratista = @pIdContratista
				and pc.IdContrato = con.IdContrato  
				and sc.IdContrato = con.IdContrato  
    where p.Actual = 1
    group by p.IdPresupuesto,
             p.Nombre,
             p.Comentario,
             p.FechaAprobacionPEP,
             P.IdPresupuestoCNH
    Order by p.IdPresupuesto desc

end

select *
from #tmpResult
order by IdPresupuesto desc
