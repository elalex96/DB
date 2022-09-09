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
        on pa.[IdProgramaActividad] = p.[IdProgramaActividad]
    inner join [dbo].[CO_PeriodoContrato] pc (NOLOCK)
        on pc.IdPeriodo = pa.IdPeriodoContrato
    inner join CO_Contrato con (NOLOCK)
        on con.IdContrato = pc.IdContrato
            and con.IdContratista = @pIdContratista
    inner join SC_Presupuesto scp (NOLOCK)
        on scp.IdPresupuesto = p.IdPresupuesto
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
            on pa.[IdProgramaActividad] = p.[IdProgramaActividad]
        inner join [dbo].[CO_PeriodoContrato] pc (NOLOCK)
            on pc.IdPeriodo = pa.IdPeriodoContrato
        inner join CO_Contrato con (NOLOCK)
            on con.IdContratista = @pIdContratista
				and con.IdContrato = pc.IdContrato
				and con.IdContrato = sc.IdContrato
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
